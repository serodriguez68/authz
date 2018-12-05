FactoryBot.define do
  factory :user, class: 'User' do
    email { Faker::Internet.email }
    password { "abc123" }
    password_confirmation { "abc123" }
  end
end
