require_dependency "authz/application_controller"

module Authz
  class Bulk::ControllerActionsController < ApplicationController
    def create
      if params[:create_all] = 'true'
        ActiveRecord::Base.transaction do
          @pending_actions = ::Authz::ControllerAction.pending_controller_actions
          @pending_actions.each do |controller_action_hash|
            ::Authz::ControllerAction.create!(
              controller: controller_action_hash[:controller],
              action: controller_action_hash[:action],
            )
          end
        end
        flash[:success] = "#{@pending_actions.count} successfully created!"
        redirect_back fallback_location: root_path
      else
        flash[:notice] = 'Partial bulk creation not implemented yet'
        redirect_back fallback_location: root_path
      end

    end
  end
end
