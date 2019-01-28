require_dependency "authz/application_controller"

module Authz
  class PendingControllerActionsController < ApplicationController
    def index
      @non_created_controller_actions = ControllerAction.pending_controller_actions
                                                        .sort_by { |ca| ca[:controller] }
    end
  end
end
