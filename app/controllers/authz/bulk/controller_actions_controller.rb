require_dependency "authz/application_controller"

module Authz
  # @api private
  class Bulk::ControllerActionsController < ApplicationController

    def create
      pending_actions = Authz::ControllerAction.create_all_pending!
      flash[:success] = "#{pending_actions.size} actions successfully created!"
      redirect_to root_path
    end

    def destroy
      ActiveRecord::Base.transaction do
        @stale_actions = ::Authz::ControllerAction.stale
        @stale_actions.each do |controller_action_hash|
          ::Authz::ControllerAction.find_by(
            controller: controller_action_hash[:controller],
            action: controller_action_hash[:action],
          ).destroy!
        end
      end
      flash[:success] = "#{@stale_actions.count} actions successfully destroyed!"
      redirect_to root_path
    end

  end
end
