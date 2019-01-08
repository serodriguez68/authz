FactoryBot.define do
  factory :authz_role, class: 'Authz::Role' do
    code { name.parameterize(separator: '_') }
    sequence(:name) { |n| "#{Faker::Company.profession} #{n}" }
    description { name }
  end
end
