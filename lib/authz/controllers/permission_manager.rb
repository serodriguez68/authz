module Authz
  module Controllers
    module PermissionManager

      extend ActiveSupport::Concern

      def self.has_permission?(role, controller_name, action_name)
        role.controller_actions.exists?(controller: controller_name,
                                        action: action_name)
      end

      private

      # Returns true if the user has permission for the path given as argument
      #
      # @param path_to_check [String] path or url that will be checked
      # @param method [Symbol] method of the path or url
      # @return [Boolean]
      # TODO: extend this helper to take into account the instance?
      #       this would also mean promoting it to the authorization
      #       manager.
      def authorized_path?(path_to_check, method: :get)
        recognized_controller_action = Rails.application.routes.recognize_path path_to_check, method: method
        controller_name = recognized_controller_action[:controller]
        action_name = recognized_controller_action[:action]
        authz_user.clear_for?(controller: controller_name, action: action_name)
      end

      # TODO: consider if it is worth creating an authorized_link_to helper that checks for authorization and renders
      # a link if needed. Check link_to_if  (maybe create it in another file by extending the Application Helper)

      included do |includer|
        includer.helper_method :authorized_path?
      end

    end
  end
end
