FactoryBot.define do
  factory :opinionated_pundit_role_grant, class: 'OpinionatedPundit::RoleGrant' do
    association :rolable, factory: :opinionated_pundit_business_process
    association :role, factory: :opinionated_pundit_role
  end
end
