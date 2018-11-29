FactoryBot.define do
  factory :opinionated_pundit_controller_action, class: 'OpinionatedPundit::ControllerAction' do
    controller { 'visitors' }
    action { 'index' }
  end
end