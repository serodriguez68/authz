module Authz
  module Models
    module Rolable
      extend ActiveSupport::Concern

      included do |includer|
        Authz.register_rolable(includer)

        # Associations for the includer
        # ========================================================================
        has_many :role_grants, class_name: "Authz::RoleGrant", as: 'rolable'
        has_many :roles, through: :role_grants
        has_many :business_processes, through: :roles
        has_many :controller_actions, through: :business_processes
        has_many :scoping_rules, through: :roles

        # Associations for all other classes referencing the includer
        # ========================================================================
        includer_class_name = includer.model_name.to_s
        assoc_name_to_includer = includer.authorizable_association_name

        classes_to_extend = [Authz::Role,
                             Authz::BusinessProcess,
                             Authz::ControllerAction,
                             Authz::ScopingRule]

        # E.g. business_process has_many :users, through: role_grants, source_type: user
        # business_procces.pirates will find all pirates that have been granted that
        # business process
        classes_to_extend.each do |klass|
          klass.class_eval do
            has_many assoc_name_to_includer,
                     through: :role_grants,
                     source_type: includer_class_name,
                     source: 'rolable'
          end
        end

      end

      # Mixed instance methods
      # ==========================================================================
      # Label used to label each rolable instance in the context
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

      # Returns a composite cache key using the keys of the granted roles.
      # The key will be modified when the configuration of any of the granted
      # roles changes.
      def roles_cache_key
        roles.map(&:cache_key).join('/')
      end


      # Configure Includer for Authorization Admin
      # ==========================================================================
      class_methods do
        # self = Includer Class (e.g user)

        # Developers can use this to specify which method form the includer
        # should be used inside authz to label each instance
        def authz_label_method method_name
          define_method 'authz_label' do
            self.send(method_name)
          end
        end

        # Returns a handle to the name (symbol) of the association
        # method that points from other classes to this Authorizable
        def authorizable_association_name
          model_name.plural.to_sym
        end

      end

    end
  end
end