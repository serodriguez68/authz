require 'authz/engine'
require 'authz/cache'
require 'authz/models/rolable'
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

  # The method controllers use to force authentication
  mattr_accessor :force_authentication_method
  @@force_authentication_method = :authenticate_user!

  # The method used to access the instance of a current user
  mattr_accessor :current_user_method
  @@current_user_method = :current_user

  # Configuration to enable cross request caching
  mattr_accessor :cross_request_caching
  @@cross_request_caching = false

  # The attribute that points to the cache module
  mattr_reader :cache
  @@cache = Authz::Cache

  # Allows the configuration of the gem using the
  # Authz.configure do |config| syntax
  def self.configure
    yield self
  end
end
