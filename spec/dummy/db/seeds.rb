# Users
# ==========================================================================
general_director = User.create!(email: "general_director@cia.com", password: 'password', password_confirmation: 'password')
director = User.create!(email: "director@cia.com", password: 'password', password_confirmation: 'password')
special_agent = User.create!(email: "special_agent@cia.com", password: 'password', password_confirmation: 'password')
agent = User.create!(email: "agent@cia.com", password: 'password', password_confirmation: 'password')
auditor = User.create!(email: "auditor@cia.com", password: 'password', password_confirmation: 'password')

# Clearances
# ==========================================================================
top_secret = Clearance.create!(level: 2, name: 'top-secret')
secret = Clearance.create!(level: 1, name: 'secret')

# Cities
# ==========================================================================
ny = City.create!(name: 'New York')
sf = City.create!(name: 'San Francisco')

# Report
# ==========================================================================
# Agent only creates secret reports
5.times do
  Report.create!(user: agent, clearance: secret, city: ny,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
end

# Special agent creates both secret and top-secret reports
5.times do
  Report.create!(user: special_agent, clearance: secret, city: sf,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
end
5.times do
  Report.create!(user: special_agent, clearance: top_secret, city: sf,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
end

# ==========================================================================
# Engine
# ==========================================================================

# Controller Actions
# ==========================================================================
Authz::ControllerAction.reachable_controller_actions.each do |controller, actions|
  actions.each do |action|
    Authz::ControllerAction.create!(
        controller: controller,
        action: action)
  end
end

# Business Processes
# ==========================================================================
controllers_to_include = ["clearances", "cities", "reports"]
processes_to_create = ["View", "Manage"]
controllers_to_include.each do |controller|
  processes_to_create.each do |process|
    name = "#{process} #{controller}"
    bp = Authz::BusinessProcess.create!(name: name, description: name)

    if process == "View"
      cas = Authz::ControllerAction.where(controller: controller,
                                                      action: %w(index show))
    elsif process == "Manage"
      cas = Authz::ControllerAction.where(controller: controller)
    end
    bp.controller_actions << cas
  end
end

# Roles and mapping to business processes and role grants
# ==========================================================================
roles_to_create = %w(general_director director special_agent agent auditor)
roles_to_create.each do |role_name|
  role = Authz::Role.create!(name: role_name, description: role_name)

  # Mapping to business processes
  if role.name == 'auditor'
    bps = Authz::BusinessProcess.where("name LIKE ?", "%view%")
  else
    bps = Authz::BusinessProcess.all
  end
  role.business_processes << bps

  # Mapping to role grants
  eval(role.name).roles << role
end


# Scoping Rules
# ==========================================================================
r = Authz::Role.find_by(name: 'general_director')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByCity', keyword: 'All')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: 'All')

r = Authz::Role.find_by(name: 'auditor')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByCity', keyword: 'All')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: 'All')

r = Authz::Role.find_by(name: 'agent')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByCity', keyword: sf.name)
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: secret.name)