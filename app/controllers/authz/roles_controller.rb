require_dependency "authz/application_controller"

module Authz
  class RolesController < ApplicationController

    def index
      @roles = Role.all.page(params[:roles_page])
    end

    def show
      @role = Role.find(params[:id])
      @associated_controller_actions = @role.controller_actions.distinct.page(params[:controller_actions_page]).per(10)
      @associated_business_processes = @role.business_processes.distinct.page(params[:business_processes_page]).per(10)
      @scoping_rules = {}
      ::Authz::Scopables::Base.get_scopables_modules.each do |scoping_module|
        @scoping_rules[scoping_module.to_s] = ScopingRule.find_by(scopable: scoping_module.to_s,
                                                                  role: @role)
      end
    end

    def new
      @role = Role.new
    end

    def create
      @role = Role.new(role_params)
      if @role.save
        flash[:success] = "#{@role.name} created successfully"
        redirect_to role_path(@role)
      else
        flash.now[:error] = "There was an issue creating this role"
        render 'new'
      end
    end

    def edit
      @role = Role.find(params[:id])
    end

    def update
      @role = Role.find(params[:id])
      if @role.update(role_params)
        flash[:success] = "#{@role.name} updated successfully"
        redirect_to role_path(@role)
      else
        flash.now[:error] = "There was an issue updating this role"
        render 'edit'
      end
    end

    def destroy
      @role = Role.find(params[:id])
      if @role.destroy
        flash[:success] = "#{@role.name} destroyed successfully"
        redirect_to roles_path
      else
        flash.now[:error] = "There was an issue destroying #{@role.name}"
        render 'show'
      end
    end

    private

    def role_params
      permitted_arguments = [:name, :description, business_process_ids: []]
      ::Authz.rolables.each do |rolable|
        permitted_arguments << { "#{rolable.model_name.singular}_ids"=> [] }
      end
      params.require(:role)
            .permit(permitted_arguments)
    end
  end
end
