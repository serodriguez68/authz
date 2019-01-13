require_dependency "authz/application_controller"

module Authz
  class Validations::RoleNamesController < ApplicationController
    def new
      name = params[:role][:name]
      # found = BusinessProcess.exists?(name: name)
      found = Role.exists?(code: name.parameterize(separator: '_'))

      respond_to do |format|
        format.json {render :json => !found}
      end
    end
  end
end
