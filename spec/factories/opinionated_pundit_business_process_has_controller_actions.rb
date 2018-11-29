FactoryBot.define do
  factory :opinionated_pundit_business_process_has_controller_action, class: 'OpinionatedPundit::BusinessProcessHasControllerAction' do
    association :controller_action, factory: :opinionated_pundit_controller_action
    association :business_process, factory: :opinionated_pundit_business_process
  end
end
