FactoryBot.define do
  factory :authz_role_has_business_process, class: 'Authz::RoleHasBusinessProcess' do
    association :business_process, factory: :authz_business_process
    association :role, factory: :authz_role
  end
end
