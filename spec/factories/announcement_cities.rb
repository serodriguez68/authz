FactoryBot.define do
  factory :announcement_city, class: 'Announcement' do
    association :announcement
    association :city
  end
end
