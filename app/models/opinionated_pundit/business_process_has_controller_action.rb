module OpinionatedPundit
  class BusinessProcessHasControllerAction < ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :controller_action, class_name: 'OpinionatedPundit::ControllerAction',
                                   foreign_key: 'opinionated_pundit_controller_action_id'
    belongs_to :business_process, class_name: 'OpinionatedPundit::BusinessProcess',
                                  foreign_key: 'opinionated_pundit_business_process_id'

    # Validations
    # ===========================================================================
    validates :opinionated_pundit_controller_action_id,
              uniqueness: { scope: [:opinionated_pundit_business_process_id] }
  end
end
