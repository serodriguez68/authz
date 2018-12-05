FactoryBot.define do
  factory :authz_business_process, class: 'Authz::BusinessProcess' do
    code { 'manage_reports' }
    name { 'Manage Reports' }
    description { 'Contains a human readable description of what the process is' }
  end
end
