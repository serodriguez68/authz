module Authz
  module Models
    module Authorizable
      extend ActiveSupport::Concern

      included do |includer|
        Authz.register_rolable(includer)

        # Associations for the includer
        # ========================================================================
        has_many :role_grants, class_name: "Authz::RoleGrant", as: 'rolable'
        has_many :roles, through: :role_grants
        has_many :business_processes, through: :roles
        has_many :controller_actions, through: :business_processes

        # Associations for all other classes referencing the includer
        # ========================================================================
        includer_class_name = includer.model_name.to_s
        includer_pluralized_symbol = includer_class_name
                                     .parameterize(separator: '_')
                                     .pluralize.to_sym

        classes_to_extend = [Authz::Role,
                             Authz::BusinessProcess,
                             Authz::ControllerAction]

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

      # Label used to label each authorizable instance in the context
      # of Authz
      def authz_label
        if respond_to? :name
          name
        elsif respond_to? :email
          email
        elsif respond_to? :id
          "#{self.to_s}##{id}"
        else
          to_s
        end
      end

      # Configure Includer for Authorization Admin
      # ==========================================================================
      class_methods do
        # Developers must use this method to register the includer on the
        # authorization admin specifying which field of attribute
        # (real or virtual)should be used in the admin to identify each
        # instance.
        # (e.g.  Users will be identified by :email)
        # TODO: Modify or remove this if getting rid of Rails Admin
        def register_in_authorization_admin(identifier:)
          Authz.register_authorizable_in_admin(self, identifier)
        end

        # Developers can use this to specify which method form the includer
        # should be used inside authz to label each instance
        def authz_label_method method_name
          define_method 'authz_label' do
            self.send(method_name)
          end
        end

      end

    end
  end
end