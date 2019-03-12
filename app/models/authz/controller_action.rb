module Authz
  # Represents a single reachable controller
  # action from the host application's router, including all library
  # internal routes.
  class ControllerAction < self::ApplicationRecord

    # Validations
    # ==========================================================================
    validates :controller, presence: true
    validates :action, presence: true
    validates_uniqueness_of :controller, scope: %i[action]
    validate :controller_action_pair_exist

    # Associations
    # ==========================================================================
    has_many :business_process_has_controller_actions,
             class_name: 'Authz::BusinessProcessHasControllerAction',
             foreign_key: 'authz_controller_action_id',
             inverse_of: :controller_action,
             dependent: :destroy
    has_many :business_processes,
             through: :business_process_has_controller_actions,
             dependent: :destroy
    has_many :roles, through: :business_processes
    has_many :role_grants, through: :roles

    accepts_nested_attributes_for :business_processes

    # Callbacks
    # ==========================================================================
    after_update :touch_upstream_instances

    # Class Methods
    # ==========================================================================

    # @return [Hash] reachable controller actions declared in the host app's router
    def self.main_app_reachable_controller_actions
      extract_reachable_controller_actions(Rails.application)
    end

    # @return [Hash] reachable controller actions declared in the Engine's router
    def self.engine_reachable_controller_actions
      extract_reachable_controller_actions(Authz::Engine)
    end

    # Combines the reachable controller actions from the engine and the main app
    # giving precedence to the main app in case of overwrite
    # @return [Hash] reachable controller actions
    # @see .main_app_reachable_controller_actions
    # @see .engine_reachable_controller_actions
    def self.reachable_controller_actions
      app_cas = main_app_reachable_controller_actions
      engine_cas =  engine_reachable_controller_actions
      repeated_keys = app_cas.keys & engine_cas.keys
      res = engine_cas.merge(app_cas)
      repeated_keys.each { |rk| res[rk] = app_cas[rk] | engine_cas[rk] }
      res
    end

    # @return [Array<Authz::ControllerAction>]
    #         controller action instances reachable from the router but not present in the database
    # @api private
    # @see .reachable_controller_actions
    def self.pending
      router_ca_pairs = []
      reachable_controller_actions.each do |c_name, action_arr|
        action_arr.each do |a_name|
          router_ca_pairs << [c_name, a_name]
        end
      end

      dp_ca_pairs = all.pluck(:controller, :action)

      pending = router_ca_pairs - dp_ca_pairs
      pending.map{ |ca_pair| new(controller: ca_pair.first, action: ca_pair.last) }
    end

    # @return [Array<Authz::ControllerAction>] controller actions that are created in the database that
    #         are no longer reachable from the router
    # @api private
    # @see .reachable_controller_actions
    def self.stale
      # TODO: Refactor and test
      stale = []
      find_each do |ca|
        is_included = reachable_controller_actions[ca.controller].try(:include?, ca.action)
        stale << ca unless is_included
      end
      stale
    end

    # Creates all pending controller actions in the database.
    # The creation either succeeds or fails completely
    # @return [Array<Authz::ControllerAction>] all controller action instances
    #         that have been created.
    # @api private
    # @see .pending
    def self.create_all_pending!
      transaction do
        pending.each do |pca|
          pca.save!
        end
      end
    end

    # Instance Methods
    # ==========================================================================

    # @return [String] concatenation of controller#action-id
    def to_s
      "#{controller}##{action}-#{id}"
    end

    # @return [String] description of a controller action, parsed through the
    #                  controller_metadata_service
    def description
      Authz.metadata_service.get_controller_action_description(self.controller, self.action)
    end

    private

    # Introspects the given application's or engine's routes and returns a list
    # of hashes of all reachable controller actions with the format
    # { "orders" =>["new", "edit", "update"],
    #   "authz/business_processes" => ["index", ...]  }
    # @param app: An instance of a rails application or Engine
    #             e.g. Rails.application or Authz::Engine
    def self.extract_reachable_controller_actions(app)
      result = {}
      routes = app.routes.set.anchored_routes.map(&:defaults).uniq
      routes.each do |route|
        controller = route[:controller]
        action = route[:action]
        if result.has_key? controller
          result[controller].push(action)
        else
          result[controller] = [action]
        end
      end
      result
    end

    def controller_action_pair_exist
      unless self.class.reachable_controller_actions[controller].try(:include?, action)
        errors.add(:base, 'the controller action you are trying to save is not included in the routes')
      end
    end

    def touch_upstream_instances
      time = Time.now
      business_process_has_controller_actions.update_all(updated_at: time)
      business_processes.update_all(updated_at: time)
      roles.update_all(updated_at: time)
    end

  end
end
