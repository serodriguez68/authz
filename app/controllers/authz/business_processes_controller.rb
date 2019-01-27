require_dependency "authz/application_controller"

module Authz
  class BusinessProcessesController < ApplicationController

    def index
      @business_processes = BusinessProcess.all.order(created_at: :desc).page(params[:business_processes_page])
    end

    def show
      @business_process = BusinessProcess.find(params[:id])
      @associated_controller_actions = @business_process.controller_actions.distinct.page(params[:controller_actions_page]).per(10)
      @associated_roles = @business_process.roles.distinct.page(params[:roles_page]).per(10)
    end

    def new
      @business_process = BusinessProcess.new
    end

    def create
      @business_process = BusinessProcess.new(business_process_params)
      if @business_process.save
        redirect_to business_process_path(@business_process)
        flash[:success] = "#{@business_process.name} created successfully"
      else
        render 'new'
        flash[:error] = "There was an issue creating this business process"
      end
    end

    def edit
      @business_process = BusinessProcess.find(params[:id])
    end

    def update
      @business_process = BusinessProcess.find(params[:id])
      if @business_process.update(business_process_params)
        flash[:success] = "#{@business_process.name} updated successfully"
        redirect_to business_process_path(@business_process)
      else
        flash[:error] = "There was an issue updating this business process"
        render 'edit'
      end
    end

    def destroy
      @business_process = BusinessProcess.find(params[:id])
      if @business_process.destroy
        flash[:success] = "#{@business_process.name} destroyed successfully"
        redirect_to business_processes_path
      else
        flash[:error] = "There was an issue destroying #{@business_process.name}"
        render 'show'
      end
    end

    private

    def business_process_params
      params.require(:business_process)
            .permit(
              :name,
              :description,
              controller_action_ids: [],
              role_ids: []
            )
    end
  end
end
