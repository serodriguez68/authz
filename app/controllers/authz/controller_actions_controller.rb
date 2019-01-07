require_dependency "authz/application_controller"

module Authz
  class ControllerActionsController < ApplicationController
    def index
      @controller_actions = ControllerAction.all.page(params[:page])
    end

    def show
      @controller_action = ControllerAction.find(params[:id])
      @associated_business_processes = @controller_action.business_processes.distinct.page(1)
      @associated_roles = @controller_action.roles.distinct.page(1)
      @authorized_instances = @controller_action.role_grants.page(1)
    end

    def new
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end
  end
end
