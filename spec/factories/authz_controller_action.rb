FactoryBot.define do
  factory :authz_controller_action, class: 'Authz::ControllerAction' do
    controller { Authz::ControllerAction.reachable_controller_actions.to_a.sample[0] }
    action { Authz::ControllerAction.reachable_controller_actions[controller].sample }
  end
end