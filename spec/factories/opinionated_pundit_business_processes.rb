FactoryBot.define do
  factory :opinionated_pundit_business_process, class: 'OpinionatedPundit::BusinessProcess' do
    code { 'manage_reports' }
    name { 'Manage Reports' }
    description { 'Contains a human readable description of what the process is' }
  end
end
