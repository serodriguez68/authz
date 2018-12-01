module OpinionatedPundit
  module Authorizable
    extend ActiveSupport::Concern

    included do |includer|
      OpinionatedPundit.register_rolable(includer)

      # Associations for the includer
      # ==========================================================================
      has_many :role_grants, class_name: "OpinionatedPundit::RoleGrant", as: 'rolable'
      has_many :roles, through: :role_grants
      has_many :business_processes, through: :roles
      has_many :controller_actions, through: :business_processes


      # Associations for all other classes referencing the includer
      # ==========================================================================
      includer_class_name = includer.model_name.to_s
      includer_pluralized_symbol = includer_class_name.underscore.pluralize.to_sym

      classes_to_extend = [OpinionatedPundit::Role,
                           OpinionatedPundit::BusinessProcess,
                           OpinionatedPundit::ControllerAction]

      # E.g. business_process has_many :users, through: role_grants, source_type: user
      # business_procces.pirates will find all pirates that have been granted that
      # business process
      classes_to_extend.each do |klass|
        klass.class_eval do
          has_many includer_pluralized_symbol,
                   through: :role_grants,
                   source_type: includer_class_name,
                   source: 'rolable'
        end
      end
    end

    # Mixed instance methods
    # ==========================================================================
    # Receives a stringified controller name and action name and verifies if
    # the caller has access to that endpoint
    def clear_for? controller:, action:
      controller_actions.exists?(controller: controller, action: action)
    end

  end
end