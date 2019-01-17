require_dependency "authz/application_controller"

module Authz
  class HomeController < ApplicationController
    def index
      routes = Rails.application.routes.set.anchored_routes.map(&:defaults).uniq
      not_found = []
      routes.each do |route|
        ca = ControllerAction.find_by(controller: route[:controller], action: route[:action])
        not_found << route unless ca
      end
      @non_created_controller_actions = not_found
      @invalid_scoping_rules = ScopingRule.where.not(scopable: Authz::Scopables::Base.get_scopables_names).pluck(:scopable).uniq
    end
  end
end
