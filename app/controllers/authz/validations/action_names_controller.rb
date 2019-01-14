require_dependency "authz/application_controller"

module Authz
  class Validations::ActionNamesController < ApplicationController
    def new
      _controller_name = params[:controller_name]
      _action_name = params[:controller_action][:action]
      found = ControllerAction.reachable_controller_actions[_controller_name].try(:include?, _action_name)

      respond_to do |format|
        format.json {render :json => found}
      end
    end
  end
end
