FactoryBot.define do
  factory :opinionated_pundit_role_has_business_process, class: 'OpinionatedPundit::RoleHasBusinessProcess' do
    association :business_process, factory: :opinionated_pundit_business_process
    association :role, factory: :opinionated_pundit_role
  end
end
