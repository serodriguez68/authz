module Authz
  module SeedAdmin

    # Creates the Controller Action Records needed to authorize the use of the admin
    # @return Collection of the created controller actions
    def self.create_controller_actions!
      Authz::ControllerAction.engine_reachable_controller_actions.each do |controller, actions|
        actions.each do |action|
          Authz::ControllerAction.create!(
            controller: controller,
            action: action)
        end
      end
      Authz::ControllerAction.where('controller LIKE ?', 'authz/%')
    end

    # Creates the business process that will group all the authz controller
    # actions
    # @return the created business process
    def self.create_manage_auth_business_process!
      name = 'Manage Authorization'
      desc = 'A role that is granted this business process will have full access to the Authorization Admin'
      Authz::BusinessProcess.create!(name: name, description: desc)
    end

    # Grants the given controller actions to the given business process
    def self.grant_controller_actions_to_business_process!(business_process, controller_actions)
      business_process.controller_actions << controller_actions
    end

    # Runs the seed process as a DB transaction
    # @ return: the business process
    def self.run!
      ActiveRecord::Base.transaction do
        cas = create_controller_actions!
        bp = create_manage_auth_business_process!
        grant_controller_actions_to_business_process!(bp, cas)
        bp
      end
    end

  end
end



namespace :authz do
  desc 'Seeds the database with the business processes and controller action records required to authorize the Authz Admin'
  task seed_admin: :environment do
    puts 'Creating everything you need to control access to the Authorization Admin...'
    bp = Authz::SeedAdmin.run!
    puts 'Done!'
    puts "Grant the '#{bp.name}' business process to any roles that should have full access to the Authorization Admin."
    puts 'If you have not created a role yet, check the documentation to learn how to do it.'
  end
end
