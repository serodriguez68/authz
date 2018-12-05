FactoryBot.define do
  factory :authz_business_process_has_controller_action, class: 'Authz::BusinessProcessHasControllerAction' do
    association :controller_action, factory: :authz_controller_action
    association :business_process, factory: :authz_business_process
  end
end
