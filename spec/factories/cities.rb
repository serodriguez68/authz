FactoryBot.define do
  factory :city, class: 'City' do
    name { Faker::Address.city }
  end
end
