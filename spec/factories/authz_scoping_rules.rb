FactoryBot.define do
  factory :authz_scoping_rule, class: 'Authz::ScopingRule' do
    scopable { Authz::Scopables::Base.get_scopables_names.sample }
    association :role, factory: :authz_role
    keyword { scopable.constantize.available_keywords.first }
  end
end
