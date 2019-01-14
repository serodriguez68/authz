module Authz
  class RoleGrant < ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :role, class_name: 'Authz::Role',
                      foreign_key: 'authz_role_id',
                      optional: true
    belongs_to :rolable, polymorphic: true

    # Validations
    # ===========================================================================
    validates :authz_role_id,
              uniqueness: { scope: [:rolable_type, :rolable_id] }
  end
end
