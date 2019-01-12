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
      @controller_action = ControllerAction.new
    end

    def create
      @controller_action = ControllerAction.new(controller_action_create_params)
      if @controller_action.save
        redirect_to controller_action_path(@controller_action)
      else
        render 'new'
      end
    end

    def edit
      @controller_action = ControllerAction.find(params[:id])
    end

    def update
      @controller_action = ControllerAction.find(params[:id])
      if @controller_action.update(controller_action_update_params)
        redirect_to controller_action_path(@controller_action)
      else
        render 'edit'
      end
    end

    def destroy
    end

    private

    def controller_action_create_params
      params.require(:controller_action)
            .permit(
              :controller,
              :action,
              business_process_ids: []
            )
    end

    def controller_action_update_params
      params.require(:controller_action)
            .permit(
              :controller,
              :action,
              business_process_ids: []
            )
    end
  end
end
