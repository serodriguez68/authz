module Authz
  class BusinessProcessHasControllerAction < ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :controller_action, class_name: 'Authz::ControllerAction',
                                   foreign_key: 'authz_controller_action_id'
    belongs_to :business_process, class_name: 'Authz::BusinessProcess',
                                  foreign_key: 'authz_business_process_id'

    # Validations
    # ===========================================================================
    validates :authz_controller_action_id,
              uniqueness: { scope: [:authz_business_process_id] }
  end
end
