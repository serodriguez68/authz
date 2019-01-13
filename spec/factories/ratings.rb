FactoryBot.define do
  factory :rating, class: 'Rating' do
    association :report
    association :user
    score { (1..5).to_a.sample }
  end
end