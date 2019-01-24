module Authz
  class BusinessProcessHasControllerAction < ApplicationRecord
    # Associations
    # ==========================================================================
    belongs_to :controller_action, class_name: 'Authz::ControllerAction',
                                   foreign_key: 'authz_controller_action_id',
                                   optional: true
    belongs_to :business_process, class_name: 'Authz::BusinessProcess',
                                  foreign_key: 'authz_business_process_id',
                                  optional: true,
                                  touch: true

    # Validations
    # ===========================================================================
    validates :authz_controller_action_id,
              uniqueness: { scope: [:authz_business_process_id] }
  end
end
