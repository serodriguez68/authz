require_dependency "authz/application_controller"

module Authz
  # @api private
  class Bulk::ControllerActionsController < ApplicationController

    def create
      if params[:create_all] = 'true'
        ActiveRecord::Base.transaction do
          @pending_actions = ::Authz::ControllerAction.pending
          @pending_actions.each do |controller_action_hash|
            ::Authz::ControllerAction.create!(
              controller: controller_action_hash[:controller],
              action: controller_action_hash[:action],
            )
          end
        end
        flash[:success] = "#{@pending_actions.count} actions successfully created!"
        redirect_to root_path
      else
        flash[:notice] = 'Partial bulk creation not implemented yet'
        redirect_to root_path
      end
    end

    def destroy
      if params[:destroy_all] = 'true'
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
      else
        flash[:notice] = 'Partial bulk deletion not implemented yet'
        redirect_to root_path
      end
    end

  end
end
