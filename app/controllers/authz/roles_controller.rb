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
