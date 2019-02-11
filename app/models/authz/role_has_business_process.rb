module Authz
  # An instance represents a single mapping between a role and a business process.
  # For example <Publisher, release reports>
  class RoleHasBusinessProcess < self::ApplicationRecord

    # Associations
    # ==========================================================================
    belongs_to :business_process, class_name: 'Authz::BusinessProcess',
               foreign_key: 'authz_business_process_id',
               inverse_of: :role_has_business_processes
    belongs_to :role, class_name: 'Authz::Role',
               foreign_key: 'authz_role_id',
               inverse_of: :role_has_business_processes,
               touch: true

    # Validations
    # ===========================================================================
    validates :authz_business_process_id,
              uniqueness: { scope: [:authz_role_id] }


  end
end
