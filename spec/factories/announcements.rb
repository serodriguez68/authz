FactoryBot.define do
  factory :announcement do
    body { Faker::Lorem.sentence }
  end
end
