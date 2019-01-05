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

    # Associations
    # ==========================================================================
    has_many :role_has_business_processes,
             class_name: 'Authz::RoleHasBusinessProcess',
             foreign_key: 'authz_role_id'
    has_many :business_processes, through: :role_has_business_processes
    has_many :controller_actions, through: :business_processes
    has_many :role_grants,
             class_name: 'Authz::RoleGrant',
             foreign_key: 'authz_role_id'
    has_many :scoping_rules,
             class_name: 'Authz::ScopingRule',
             foreign_key: 'authz_role_id'

    private

    def extract_code_from_name
      self.code = name.parameterize(separator: '_') if name.present?
    end
  end
end
