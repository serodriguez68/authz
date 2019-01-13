FactoryBot.define do
  factory :clearance, class: 'Clearance' do
    level { 1 }
    sequence(:name) { |n| "#{Faker::Color.color_name} #{n}" }
  end
end
