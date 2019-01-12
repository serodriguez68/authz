require_dependency "authz/application_controller"

module Authz
  class RolesController < ApplicationController

    def index
      @roles = Role.all.page(params[:page])
    end

    def show
      @role = Role.find(params[:id])
      @associated_controller_actions = @role.controller_actions.distinct.page(1)
      @associated_business_processes = @role.business_processes.distinct.page(1)
      @authorized_instances = @role.role_grants.page(1)

    end

    def new
      @role = Role.new
    end

    def create
      @role = Role.new(role_params)
      if @role.save
        redirect_to role_path(@role)
      else
        render 'new'
      end
    end

    def edit
      @role = Role.find(params[:id])
    end

    def update
      @role = Role.find(params[:id])
      if @role.update(role_params)
        redirect_to role_path(@role)
      else
        render 'edit'
      end
    end

    def destroy
    end

    def role_params
      params.require(:role)
            .permit(
              :name,
              :description,
            )
    end
  end
end
