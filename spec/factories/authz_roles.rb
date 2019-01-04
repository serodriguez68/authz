FactoryBot.define do
  factory :authz_role, class: 'Authz::Role' do
    code { name.underscore }
    name { Faker::Company.profession }
    description { name }
  end
end
