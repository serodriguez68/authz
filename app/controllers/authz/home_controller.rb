require_dependency "authz/application_controller"

module Authz
  class HomeController < ApplicationController
    def index
      @pending_controller_actions = ControllerAction.pending
      @stale_controller_actions = ControllerAction.stale
      @invalid_scoping_rules = ScopingRule.where.not(scopable: Authz::Scopables::Base.get_scopables_names).pluck(:scopable).uniq
    end
  end
end
