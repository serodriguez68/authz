require_relative 'boot'

require "rails/all"

Bundler.require(*Rails.groups)
require "authz"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # FIXME: Loading multiple rails versions for testing using appraisals and loading the defaults of just one
    #   version can cause the tests to be unstable. Figure out a way of changing the config dynamically in a more
    #   robust way.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

