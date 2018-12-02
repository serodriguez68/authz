# TODO: Test This
module OpinionatedPundit
  module Controllers
    module PermissionManager

      extend ActiveSupport::Concern

      # Errors
      # ===========================================================================
      # Error that will be raised if a user is trying to access a controller action
      # that is out of his permission privileges
      class PermissionNotGranted < StandardError; end
      # Errors ====================================================================

      # Raises an exception if the user does not have permission for the given
      # controller_name, action_name pair
      #
      # @param user [User] user whose permissions will be checked
      # @param controller_name [String] name of controller that is being accessed
      # @param action_name [String] name of action that is being accessed
      # @return [void]
      def self.check_permission!(user, controller_name, action_name)
        unless user.clear_for?(controller: controller_name, action: action_name)
          raise PermissionNotGranted, "#{user.model_name.singular} #{user.id} does not have permission for: #{controller_name}##{action_name}"
        end
      end


      private

      # Returns true if the user has permission for the path given as argument
      #
      # @param path_to_check [String] path or url that will be checked
      # @param method [Symbol] method of the path or url
      # @return [Boolean]
      def authorized_path?(path_to_check, method: :get)
        recognized_controller_action = Rails.application.routes.recognize_path path_to_check, method: method
        controller_name = recognized_controller_action[:controller]
        action_name = recognized_controller_action[:action]
        opinionated_pundit_user.clear_for?(controller: controller_name, action: action_name)
      end

      # TODO: consider if it is worth creating an authorized_link_to helper that checks for authorization and renders
      # a link if needed. Check link_to_if  (maybe create it in another file by extending the Application Helper)

      included do |includer|
        includer.helper_method :authorized_path?
      end

    end
  end
end
