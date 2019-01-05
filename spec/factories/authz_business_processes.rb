FactoryBot.define do
  factory :authz_business_process, class: 'Authz::BusinessProcess' do
    code { name.parameterize(separator: '_') }
    sequence(:name) { |n| "#{Faker::Company.profession} #{n}" }
    description { name }
  end
end
