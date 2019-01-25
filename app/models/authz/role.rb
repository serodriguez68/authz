module Authz
  class Role < self::ApplicationRecord
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

    # Associations
    # ==========================================================================
    has_many :role_has_business_processes,
             class_name: 'Authz::RoleHasBusinessProcess',
             foreign_key: 'authz_role_id',
             inverse_of: :role,
             dependent: :destroy
    has_many :business_processes,
             through: :role_has_business_processes,
             dependent: :destroy
    has_many :controller_actions,
             through: :business_processes
    has_many :role_grants,
             class_name: 'Authz::RoleGrant',
             foreign_key: 'authz_role_id',
             inverse_of: :role,
             dependent: :destroy
    has_many :scoping_rules,
             class_name: 'Authz::ScopingRule',
             foreign_key: 'authz_role_id',
             inverse_of: :role,
             dependent: :destroy

    # Returns true if the role has access to the given controller action
    def has_permission?(controller_name, action_name)
      controller_actions.exists?(controller: controller_name, action: action_name)
    end

    # Cached version of has_permission?
    def cached_has_permission?(controller_name, action_name)
      Authz.cache.fetch([cache_key, controller_name, action_name]) do
        has_permission?(controller_name, action_name)
      end
    end

    # Returns the applicable keywords according to the role's
    # scoping rule for the given scopable
    # Raises exception if the role does not have a scoping rule
    # for the given scopable
    def granted_keyword_for(scopable)
      scoping_rules.find_by!(scopable: scopable.to_s).keyword
    end

    # Cached version of #granted_keyword_for
    def cached_granted_keyword_for(scopable)
      Authz.cache.fetch([cache_key, scopable.to_s]) do
        granted_keyword_for(scopable)
      end
    end

    private

    def extract_code_from_name
      self.code = name.parameterize(separator: '_') if name.present?
    end

  end
end
