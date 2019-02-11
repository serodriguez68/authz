module Authz
  # Inherits from the host app's ApplicationController so that all of it's methods
  # are available for the engine.
  #
  # All engine's controllers inherit from this class.
  # @api private
  class ApplicationController < ::ApplicationController
    include Authz::Controllers::AuthorizationManager

    protect_from_forgery with: :exception
    before_action :authenticate_authz_user
    before_action { authorize skip_scoping: true }
    around_action :verify_authorized

    private
    # Calls the authentication method configured by the main application
    def authenticate_authz_user
      send(Authz.force_authentication_method)
    end

  end
end
