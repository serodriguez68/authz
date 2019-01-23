module Authz
  class RoleHasBusinessProcess < ApplicationRecord

    # Associations
    # ==========================================================================
    belongs_to :business_process, class_name: 'Authz::BusinessProcess',
               foreign_key: 'authz_business_process_id',
               inverse_of: :role_has_business_processes
    belongs_to :role, class_name: 'Authz::Role',
               foreign_key: 'authz_role_id'

    # Validations
    # ===========================================================================
    validates :authz_business_process_id,
              uniqueness: { scope: [:authz_role_id] }

  end
end
