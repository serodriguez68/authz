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
      @business_process = BusinessProcess.new
    end

    def create
      @business_process = BusinessProcess.new(business_process_params)
      if @business_process.save
        redirect_to business_process_path(@business_process)
      else
        render 'new'
      end
    end

    def edit
      @business_process = BusinessProcess.find(params[:id])
    end

    def update
      @business_process = BusinessProcess.find(params[:id])
      if @business_process.update(business_process_params)
        redirect_to business_process_path(@business_process)
      else
        render 'edit'
      end
    end

    def destroy
    end

    private

    def business_process_params
      params.require(:business_process)
            .permit(
              :name,
              :description
            )
    end
  end
end
