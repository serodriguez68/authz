require_dependency "authz/application_controller"

module Authz
  # Handles the controller actions related to the rolables
  # @api private
  class RolablesController < ApplicationController

    def index
      @rolables = rolable.all.page(params[:page])
    end

    def show
      @rolable = rolable.find(params[:id])
      @associated_roles = @rolable.roles.page(1)
      @associated_business_processes = @rolable.business_processes.page(params[:business_processes_page])
      @associated_controller_actions = @rolable.controller_actions.page(params[:controller_actions_page])
    end

    def edit
      @rolable = rolable.find(params[:id])
    end

    def update
      @rolable = rolable.find(params[:id])
      if @rolable.update(rolable_params)
        flash[:success] = "#{@rolable.authz_label} updated successfully"
        redirect_to send("#{@rolable.model_name.singular}_path", @rolable)
      else
        flash.now[:error] = "There was an issue updating #{@rolable.authz_label}"
        render 'edit'
      end
    end

    private

    def rolable
      ::Authz.rolables.each do |klass|
        klass_name = klass.authorizable_association_name
        regex = /\A\/#{klass_name}(\/|\z)/
        next unless regex.match request.path_info
        return klass
      end
    end

    def rolable_params
      params.require(rolable.model_name.singular)
        .permit(role_ids: [])
    end


  end
end
