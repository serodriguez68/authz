module OpinionatedPundit
  class RoleHasBusinessProcess < ApplicationRecord

    # Associations
    # ==========================================================================
    belongs_to :business_process, class_name: 'OpinionatedPundit::BusinessProcess',
               foreign_key: 'opinionated_pundit_business_process_id'
    belongs_to :role, class_name: 'OpinionatedPundit::Role',
               foreign_key: 'opinionated_pundit_role_id'

    # Validations
    # ===========================================================================
    validates :opinionated_pundit_business_process_id,
              uniqueness: { scope: [:opinionated_pundit_role_id] }

  end
end
