# Users
# ==========================================================================
general_director = User.create!(email: "general_director@cia.com", password: 'password', password_confirmation: 'password')
ny_director = User.create!(email: "ny_director@cia.com", password: 'password', password_confirmation: 'password')
sf_director = User.create!(email: "sf_director@cia.com", password: 'password', password_confirmation: 'password')
ny_agent = User.create!(email: "ny_agent@cia.com", password: 'password', password_confirmation: 'password')
sf_agent = User.create!(email: "sf_agent@cia.com", password: 'password', password_confirmation: 'password')
ny_auditor = User.create!(email: "ny_auditor@cia.com", password: 'password', password_confirmation: 'password')
sf_auditor = User.create!(email: "sf_auditor@cia.com", password: 'password', password_confirmation: 'password')

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
  Report.create!(user: ny_agent, clearance: secret, city: ny,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
  Report.create!(user: sf_agent, clearance: secret, city: sf,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
end

# Directors creates both secret and top-secret reports
5.times do
  Report.create!(user: ny_director, clearance: secret, city: ny,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)

  Report.create!(user: sf_director, clearance: secret, city: sf,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
end
5.times do
  Report.create!(user: ny_director, clearance: top_secret, city: ny,
                 title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)

  Report.create!(user: sf_director, clearance: top_secret, city: sf,
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

# Roles,  mapping to business processes and grant role to users
# ==========================================================================
roles_to_create = %w[general_director
                     ny_director sf_director
                     ny_agent sf_agent
                     ny_auditor sf_auditor]
roles_to_create.each do |role_name|
  role = Authz::Role.create!(name: role_name, description: role_name)

  # Mapping to business processes
  if role.name.include?'auditor'
    bps = Authz::BusinessProcess.where("name LIKE ?", "%view%")
  else
    bps = Authz::BusinessProcess.all
  end
  role.business_processes << bps

  # Mapping to role grants
  eval(role.name).roles << role
end


# Scoping Rules assigned to roles
# ==========================================================================
# General Director
r = Authz::Role.find_by(name: 'general_director')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByCity', keyword: 'All')
Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: 'All')


# Scopable By City
city_names = { 'ny' => 'New York', 'sf' => 'San Francisco' }
city_names.each do |sh, lng|
  roles = Authz::Role.where('name LIKE ?', "#{sh}%")
  roles.each do |r|
    Authz::ScopingRule.create!(role: r, scopable: 'ScopableByCity', keyword: "#{lng}")
  end
end

# Scopable By Clearance: Director
roles = Authz::Role.where(name: ['ny_director', 'sf_director'])
roles.each { |r| Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: 'All') }

# Scopable By Clearance: agent
roles = Authz::Role.where(name: ['ny_agent', 'sf_agent'])
roles.each { |r| Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: secret.name) }

# Scopable By Clearance: auditor
roles = Authz::Role.where('name LIKE ?', "%auditor%")
roles.each { |r| Authz::ScopingRule.create!(role: r, scopable: 'ScopableByClearance', keyword: 'All') }


# Announcements
# ==========================================================================
a = Announcement.create! body: "for ny and sf"
a.cities << [ny, sf]

a = Announcement.create! body: "for ny"
a.cities << [ny]

a = Announcement.create! body: "for sf"
a.cities << [sf]

Announcement.create! body: "for no one"