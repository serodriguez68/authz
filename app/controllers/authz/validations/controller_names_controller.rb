require_dependency "authz/application_controller"

module Authz
  # @api private
  class Validations::ControllerNamesController < ApplicationController
    def new
      name = params[:controller_action][:controller]
      found = ControllerAction.reachable_controller_actions[name].present?

      respond_to do |format|
        format.json {render :json => found}
      end
    end
  end
end
