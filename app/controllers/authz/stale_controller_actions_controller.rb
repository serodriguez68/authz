require_dependency "authz/application_controller"

module Authz
  # @api private
  class StaleControllerActionsController < ApplicationController
    def index
      @stale_controller_actions = ControllerAction.stale
    end
  end
end
