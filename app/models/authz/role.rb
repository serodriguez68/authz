module Authz
  class Role < ApplicationRecord
    # Validations
    # ==========================================================================
    validates :code, presence: true, uniqueness: true,
              format: { with: /\A[a-z][a-z0-9]*(_[a-z0-9]+)*\z/,
                        message: 'only snake_case allowed' }
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true

    # Callbacks
    # ==========================================================================
    before_validation :extract_code_from_name, on: [:create]
    after_touch :debug_touch

    # Associations
    # ==========================================================================
    has_many :role_has_business_processes,
             class_name: 'Authz::RoleHasBusinessProcess',
             foreign_key: 'authz_role_id',
             dependent: :destroy
    has_many :business_processes, through: :role_has_business_processes
    has_many :controller_actions, through: :business_processes
    has_many :role_grants,
             class_name: 'Authz::RoleGrant',
             foreign_key: 'authz_role_id'
    has_many :scoping_rules,
             class_name: 'Authz::ScopingRule',
             foreign_key: 'authz_role_id'

    # Returns true if the role has access to the given controller action
    def has_permission?(controller_name, action_name)
      controller_actions.exists?(controller: controller_name, action: action_name)
    end

    # Cached version of has_permission?
    def cached_has_permission?(controller_name, action_name)
      Rails.cache.fetch([cache_key_with_version, controller_name, action_name]) do
        p "refreshing cache for #{name} for #{controller_name}##{action_name}"
        has_permission?(controller_name, action_name)
      end
    end

    private

    def extract_code_from_name
      self.code = name.parameterize(separator: '_') if name.present?
    end


    private
    def debug_touch
      p "#{name} has been touched"
    end

  end
end
