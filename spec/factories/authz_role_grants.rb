FactoryBot.define do
  factory :authz_role_grant, class: 'Authz::RoleGrant' do
    association :rolable, factory: :authz_business_process
    association :role, factory: :authz_role
  end
end
