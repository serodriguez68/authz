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
      # @all_rolables = []
      # Authz.rolables.each do |rolable|
      #   @all_rolables << @business_process.public_send(rolable.pluralizado).page(params["#{}_page"])
      # end
    end

    def new
      @business_process = BusinessProcess.new
    end

    def create
      @business_process = BusinessProcess.new(business_process_params)
      if @business_process.save
        # FIXME: make sure that saving and deleting associated
        # controller_action_ids and role_ids actually go through Rails
        # and trigger cache invalidation
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
      # FIXME: make sure that saving and deleting associated
      # controller_action_ids and role_ids actually go through Rails
      # and trigger cache invalidation
      if @business_process.update(business_process_params)
        redirect_to business_process_path(@business_process)
      else
        render 'edit'
      end
    end

    def destroy
      @business_process = BusinessProcess.find(params[:id])
      if @business_process.destroy
        redirect_to business_processes_path
      else
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
