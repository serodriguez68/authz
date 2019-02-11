module Authz
  # Superclass for all internal models
  # @api private
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    # Forces the use of Rails 5.1 and below for #cache_key.
    # This is limited to the gem's inner workings so the
    # host app is not affected.
    # #cache_key will include timestamp.
    self.cache_versioning = false

  end
end
