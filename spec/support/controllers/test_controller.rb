class TestsController < ApplicationController
  include Authz::Controllers::AuthorizationManager
  public(*Authz::Controllers::AuthorizationManager.protected_instance_methods)
  public(*Authz::Controllers::AuthorizationManager.private_instance_methods)

  attr_reader :current_user, :params

  def initialize(current_user, action)
    @current_user = current_user
    @params = {controller: 'tests_controller', action: action}
  end

end