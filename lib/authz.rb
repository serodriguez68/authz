require 'authz/engine'
require 'authz/cache'
require 'authz/yard_controller_metadata_service'
require 'authz/models/rolable'
require 'authz/controllers/scoping_manager'
require 'authz/controllers/authorization_manager'
require 'authz/helpers/view_helpers'
require 'authz/scopables/base'
require 'slim-rails'
require 'kaminari'
require 'jquery-rails'
require 'font-awesome-rails'
require 'yard'


# Stores the configuration parameters of the library
# @api public
module Authz

  # Error that will be raised when multiple rolables are being used.
  class MultileRolablesNotPermitted < StandardError; end

  # @return [Rolable] classes of al rolables
  # @api private
  mattr_reader :rolables
  @@rolables = []

  # Adds a rolable to the configuration
  # @param rolable [Rolable] rolable class
  # @api private
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

  mattr_accessor :force_authentication_method
  # The method controllers use to force authentication
  @@force_authentication_method = :authenticate_user!

  mattr_accessor :current_user_method
  # The method used to access the instance of a current user
  @@current_user_method = :current_user

  mattr_accessor :cross_request_caching
  # Configuration to enable cross request caching
  @@cross_request_caching = false

  mattr_reader :cache
  # The attribute that points to the cache module
  @@cache = Authz::Cache

  mattr_reader :controller_metadata_service
  @@controller_metadata_service = Authz::YardControllerMetadataService.new

  # Allows the configuration of the gem using
  # block syntax
  # @example
  #   Authz.configure do |config|
  #     config.current_user_method = :current_user
  #   end
  def self.configure
    yield self
  end
end
