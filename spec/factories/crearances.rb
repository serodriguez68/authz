FactoryBot.define do
  factory :clearance, class: 'Clearance' do
    level { 1 }
    name { Faker::Color.color_name }
  end
end
