require_dependency "authz/application_controller"

module Authz
  class Validations::BusinessProcessNamesController < ApplicationController
    def new
      name = params[:business_process][:name]
      # found = BusinessProcess.exists?(name: name)
      found = BusinessProcess.exists?(code: name.parameterize(separator: '_'))

      respond_to do |format|
        format.json {render :json => !found}
      end
    end
  end
end
