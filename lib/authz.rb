require 'authz/engine'
require 'authz/models/rolable'
require 'authz/controllers/permission_manager'
require 'authz/controllers/scoping_manager'
require 'authz/controllers/authorization_manager'
require 'authz/helpers/view_helpers'
require 'authz/scopables/base'
require 'slim-rails'
require 'kaminari'
require 'jquery-rails'
require 'font-awesome-rails'

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
end
