FactoryBot.define do
  factory :report, class: 'Report' do
    association :user
    association :clearance
    association :city
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
  end
end
