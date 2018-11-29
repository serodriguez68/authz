FactoryBot.define do
  factory :opinionated_pundit_role, class: 'OpinionatedPundit::Role' do
    code { "city_director" }
    name { "City Director" }
    description { "A description for city director" }
  end
end
