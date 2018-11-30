module OpinionatedPundit
  class RoleGrant < ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :role, class_name: 'OpinionatedPundit::Role',
                      foreign_key: 'opinionated_pundit_role_id'
    belongs_to :rolable, polymorphic: true

    # Validations
    # ===========================================================================
    validates :opinionated_pundit_role_id,
              uniqueness: { scope: [:rolable_type, :rolable_id] }
  end
end
