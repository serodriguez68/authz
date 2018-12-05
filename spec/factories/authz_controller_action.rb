FactoryBot.define do
  factory :authz_controller_action, class: 'Authz::ControllerAction' do
    controller { 'visitors' }
    action { 'index' }
  end
end