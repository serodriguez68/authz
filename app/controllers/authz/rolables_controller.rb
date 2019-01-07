require_dependency "authz/application_controller"

module Authz
  class RolablesController < ApplicationController
    def index
      @rolables = rolable.all.page(params[:page])
    end

    def show
      @rolable = rolable.find(params[:id])
      @associated_roles = @rolable.roles.page(1)
      @associated_business_processes = @rolable.business_processes.page(1)
      @associated_controller_actions = @rolable.controller_actions.page(1)
    end

    def edit
      @rolable = rolable.find(params[:id])
    end

    def update
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


  end
end
