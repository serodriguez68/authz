module Authz
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception
    before_action :authenticate_authz_user
    include Authz::Controllers::AuthorizationManager
    around_action :verify_authorized

    private
    # Calls the authentication method configured by the main application
    def authenticate_authz_user
      send(Authz.force_authentication_method)
    end

  end
end
