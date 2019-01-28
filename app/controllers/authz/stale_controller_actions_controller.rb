require_dependency "authz/application_controller"

module Authz
  class StaleControllerActionsController < ApplicationController
    def index
      @stale_controller_actions = ControllerAction.stale
    end
  end
end
