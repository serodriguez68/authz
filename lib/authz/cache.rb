module Authz
  # This module is a wrapper of Rails.cache and serves as a central
  # point for configuring how Authz's internal Cache works depending
  # on the gem's configuration
  # @api private
  module Cache

    def self.fetch(name, options = nil, &block)
      if Authz.cross_request_caching
        Rails.cache.fetch(name, options, &block)
      else
        block.call
      end
    end

    # @return [Boolean] true the host application is running a version of active record that has cache_versioning
    #   available.
    def self.active_record_has_cache_versioning_available?
      Rails.gem_version >= Gem::Version.new("5.2.x")
    end
  end
end