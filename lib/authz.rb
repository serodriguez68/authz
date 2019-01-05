require 'authz/engine'
require 'authz/models/authorizable'
require 'authz/controllers/permission_manager'
require 'authz/controllers/authorization_manager'
require 'rails_admin'
require 'slim-rails'

module Authz

  class MultileRolablesNotPermitted < StandardError; end

  mattr_reader :rolables
  @@rolables = [] # Contains the classes of all Rolables
  def self.register_rolable(rolable)

    unless @@rolables.map{|r| r.model_name.name}.include?(rolable.model_name.name)
      @@rolables << rolable
    end

    # TODO: When support for multiple rolables is implemented, lift this exception
    if @@rolables.size > 1
      raise MultileRolablesNotPermitted,
            "Only the Authorization of one model (like a User) is currently supported"
    end
  end

  # Configures the authorizable class given as param in the authorization admin
  # using the identifier as the attribute to identify instances inside the admin
  # (e.g.  Users will be identified by :email)
  # TODO: Modify or remove this if getting rid of Rails Admin
  def self.register_authorizable_in_admin(klass, identifier)
    includer_class_name = klass.model_name.to_s
    identifier = identifier.to_sym

    RailsAdmin.config do |config|
      config.included_models << includer_class_name
      config.model includer_class_name do
        list do
          field identifier do read_only(true) end
          fields :roles, :business_processes, :controller_actions
        end
        edit do
          field identifier do read_only(true) end
          fields :roles, :business_processes, :controller_actions
        end
        show do
          field identifier do read_only(true) end
          fields :roles, :business_processes, :controller_actions
        end
      end
    end

  end

end
