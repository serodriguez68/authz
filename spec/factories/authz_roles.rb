FactoryBot.define do
  factory :authz_role, class: 'Authz::Role' do
    code { "city_director" }
    name { "City Director" }
    description { "A description for city director" }
  end
end
