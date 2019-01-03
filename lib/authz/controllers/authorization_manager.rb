module Authz
  module Controllers
    module AuthorizationManager

      extend ActiveSupport::Concern
      # include ScopingManager
      include Authz::Controllers::PermissionManager

      # Errors
      # ===========================================================================
      # Error that will be raised if a controller action has not called the
      # `authorize` or `skip_authorization` methods.
      class AuthorizationNotPerformedError < StandardError; end

      # Error that will be raised if the authorized method is not provided a
      # scoping instance and the skip_scoping option is not used
      class MissingScopingInstance < StandardError
        attr_reader :controller, :action
        def initialize(options = {})
          @controller = options.fetch :controller
          @action = options.fetch :action
          message = "#{controller}##{action}. Provide an instance to " \
                    'perform authorization or use the skip_scoping option'
          super(message)
        end
      end

      # @public api
      # ===========================================================================
      protected

      # 1. Check if the user is correctly skipping scoping
      # 2. Asks PermissionManager to check for user permission
      # 3. Asks ScopingManager to verify the user's access to the instance
      # Managers should handle their own exceptions if a problem is found
      #
      # @param [using: Object] the instance that will determine
      #        access in the ScopingManager
      # @param [skip_scoping: true] to explicitly skip scoping
      # @return [void]
      def authorize(using: nil, skip_scoping: false)
        # 1. Check if the user is correctly skipping scoping
        skip_scoping = skip_scoping == true
        if using.blank? && !skip_scoping
          raise MissingScopingInstance,
                controller: params[:controller],
                action: params[:action]
        end

        @_authorization_performed = true
        # 2. Check if user has permission to this controller action
        PermissionManager.check_permission!(authz_user,
                                            params[:controller],
                                            params[:action])

        # 3. Check if user has access to instance
        # ScopingManager.check_access_to_instance!(authz_user, using) unless skip_scoping
      end

      # Allow this action not to perform authorization.
      # @return [void]
      def skip_authorization
        @_authorization_performed = true
      end

      # Hook method to allow customization of user used in the authorization
      # process
      def authz_user
        current_user
      end

      # Raises an error if authorization has not been performed.
      # `around_action` filter and transaction rollbacks changes in db
      # if authorization was not performed.
      # http://guides.rubyonrails.org/action_controller_overview.html#after-filters-and-around-filters
      # @raise [AuthorizationNotPerformedError] if authorization has not been performed
      # @return [void]
      def verify_authorized
        # Yield gets replaced by the controller action performed: E.g. #show
        # http://stackoverflow.com/questions/27932270/how-does-an-around-action-callback-work-an-explanation-is-needed
        ActiveRecord::Base.transaction do
          yield
          raise AuthorizationNotPerformedError, "#{self.class}##{self.action_name}" unless authorization_performed?
        end
      end
      # @public api ===============================================================

      private
      # @return [Boolean] whether authorization has been performed, i.e. whether
      #                   one {#authorize} or {#skip_authorization} has been called
      def authorization_performed?
        !!@_authorization_performed
      end


    end
  end
end

