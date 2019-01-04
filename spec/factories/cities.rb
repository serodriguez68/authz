FactoryBot.define do
  factory :city, class: 'City' do
    sequence(:name) { |n| "#{Faker::Address.city} #{n}" }
  end
end
