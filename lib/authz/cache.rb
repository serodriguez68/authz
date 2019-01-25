# This module is a wrapper of Rails.cache and serves as a central
# point for configuring how Authz's internal Cache works depending
# on the gems configuration
module Authz
  module Cache

    def self.fetch(name, options = nil, &block)
      if Authz.cross_request_caching
        Rails.cache.fetch(name, options, &block)
      else
        block.call
      end
    end

  end
end