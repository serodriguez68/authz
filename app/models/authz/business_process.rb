module Authz
  class BusinessProcess < ApplicationRecord
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
    has_many :business_process_has_controller_actions,
             class_name: 'Authz::BusinessProcessHasControllerAction',
             foreign_key: 'authz_business_process_id'
    has_many :controller_actions, through: :business_process_has_controller_actions
    has_many :role_has_business_processes,
             class_name: 'Authz::RoleHasBusinessProcess',
             foreign_key: 'authz_business_process_id'
    has_many :roles, through: :role_has_business_processes
    has_many :role_grants, through: :roles

    private

    def extract_code_from_name
      self.code = name.parameterize(separator: '_') if name.present?
    end

  end
end
