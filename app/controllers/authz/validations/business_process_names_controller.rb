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

    def edit
      name = params[:business_process][:name]
      business_process = BusinessProcess.find_by(code: name.parameterize(separator: '_'))
      # found = BusinessProcess.exists?(name: name)

      found = business_process.present? && business_process.id != params[:id].to_i
      respond_to do |format|
        format.json {render :json => !found}
      end
    end

  end
end
