module Authz
  # An instance represents a single mapping between a user and a role.
  # For example <'John', 'Publisher'>
  class RoleGrant < self::ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :role, class_name: 'Authz::Role',
                      foreign_key: 'authz_role_id',
                      inverse_of: :role_grants
    belongs_to :rolable, polymorphic: true

    # Validations
    # ===========================================================================
    validates :authz_role_id,
              uniqueness: { scope: [:rolable_type, :rolable_id] }
  end
end
