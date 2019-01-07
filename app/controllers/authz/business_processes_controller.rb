require_dependency "authz/application_controller"

module Authz
  class BusinessProcessesController < ApplicationController
    def index
      @business_processes = BusinessProcess.all.page(params[:page])
    end

    def show
      @business_process = BusinessProcess.find(params[:id])
      @associated_controller_actions = @business_process.controller_actions.distinct.page(1)
      @associated_roles = @business_process.roles.distinct.page(1)
      @authorized_instances = @business_process.role_grants.page(1)
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
