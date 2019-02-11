require_dependency "authz/application_controller"

module Authz
  # @api private
  class Validations::RoleNamesController < ApplicationController
    def new
      name = params[:role][:name]
      # found = BusinessProcess.exists?(name: name)
      found = Role.exists?(code: name.parameterize(separator: '_'))

      respond_to do |format|
        format.json {render :json => !found}
      end
    end

    def edit
      name = params[:role][:name]
      roles = Role.find_by(code: name.parameterize(separator: '_'))
      # found = BusinessProcess.exists?(name: name)

      found = roles.present? && roles.id != params[:id].to_i
      respond_to do |format|
        format.json {render :json => !found}
      end
    end
  end
end
