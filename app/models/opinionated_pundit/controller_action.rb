module OpinionatedPundit
  class ControllerAction < ApplicationRecord
    # Errors
    # ==========================================================================
    # Raised if the controller action being queried does not exist
    class ControllerActionNotFound < StandardError; end

    # Validations
    # ==========================================================================
    validates :controller, presence: true
    validates :action, presence: true
    validates_uniqueness_of :controller, scope: %i[action]
    validate :controller_action_pair_exist

    # Associations
    # ==========================================================================
    has_many :business_process_has_controller_actions,
             class_name: 'OpinionatedPundit::BusinessProcessHasControllerAction',
             foreign_key: 'opinionated_pundit_controller_action_id'
    has_many :business_processes, through: :business_process_has_controller_actions

    # Class Methods
    # ==========================================================================
    # Introspects the application's routes and returns a list of hashes of all
    # reachable controller actions with the format
    # { "orders" =>["new", "edit", "update"] }
    def self.reachable_controller_actions
      result = {}
      routes = Rails.application.routes.set.anchored_routes.map(&:defaults).uniq
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

    private

    def controller_action_pair_exist
      unless self.class.reachable_controller_actions[controller].try(:include?, action)
        errors.add(:base, 'the controller action you are trying to save is not included in the routes')
      end
    end

  end
end
