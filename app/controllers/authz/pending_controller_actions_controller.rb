require_dependency "authz/application_controller"

module Authz
  class PendingControllerActionsController < ApplicationController
    def index
      @pending_controller_actions = ControllerAction.pending
                                                    .sort_by { |ca| ca[:controller] }
    end
  end
end
