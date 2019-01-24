module Authz
  module Controllers
    module AuthorizationManager

      extend ActiveSupport::Concern

      # Errors
      # ===========================================================================
      # Error that will be raised if a controller action has not called the
      # `authorize` or `skip_authorization` methods.
      class AuthorizationNotPerformedError < StandardError
        attr_reader :controller, :action
        def initialize(options = {})
          @controller = options.fetch :controller
          @action = options.fetch :action
          message = "#{controller}##{action} is missing authorization."
          super(message)
        end
      end

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

      # Error that will be raised if a user is not authorized
      class NotAuthorized < StandardError
        attr_reader :rolable, :controller, :action, :instance
        def initialize(options = {})
          @rolable = options.fetch :rolable
          @controller = options.fetch :controller
          @action = options.fetch :action
          @instance = options.fetch(:instance, nil)

          message = "#{rolable.class} #{rolable.id} " \
                    'does not have a role that allows him to ' \
                    "#{controller}##{action}"

          if instance.present?
            message += " on #{instance}."
          end

          super(message)
        end
      end

      # @public api
      # ===========================================================================
      protected

      # Enforces authorization when called.
      # Raises an exception when the unauthorized.
      # The exception may be rescued to provided custom behaviour.
      #
      # @param [using: Object] the instance that will determine
      #        access in the ScopingManager
      # @param [skip_scoping: true] to explicitly skip scoping
      # @return [void]
      def authorize(using: nil, skip_scoping: false)
        @_authorization_performed = true

        authorized = authorized?(controller: params[:controller],
                                 action: params[:action],
                                 using: using,
                                 skip_scoping: skip_scoping)
        return using if authorized

        raise NotAuthorized, rolable: authz_user,
              controller: params[:controller],
              action: params[:action],
              instance: using
      end

      # Determines if a user is authorized to perform a certain controller action
      # on a given instance
      # @param controller: name of the controller
      # @param action: name of the controller action
      # @param using: the instance used to determine scope access
      # @param skip_scoping: option for ignoring scoping during verification
      def authorized?(controller:, action:, using: nil, skip_scoping: false)
        # 1. Check if the user is correctly skipping scoping
        skip_scoping = skip_scoping == true
        if using.blank? && !skip_scoping
          raise MissingScopingInstance, controller: controller, action: action
        end

        # 2. At least one of the user's roles have both Permission and Scope
        usr = authz_user
        usr.roles.each do |role|
          # a. Check authorization on controller action
          auth_on_action = role.cached_has_permission?(controller, action)
          next unless auth_on_action

          # b. Check authorization on scoping privileges
          auth_on_scope = skip_scoping || ScopingManager.has_access_to_instance?(role, using, usr)

          # c. If a rule is fully authorized, return
          return true if auth_on_action && auth_on_scope
        end

        # 3. After searching all roles, no authorization found
        return false
      end

      # Allow this action not to perform authorization.
      # @return [void]
      def skip_authorization
        @_authorization_performed = true
      end

      # Hook method to allow customization of user used in the authorization
      # process
      def authz_user
        send(Authz.current_user_method)
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
          unless authorization_performed?
            raise AuthorizationNotPerformedError, controller: self.class,
                                                  action: self.action_name
          end
        end
      end

      # Find authz_user and forward to apply scoping rules
      #
      # @param on: collection or class on top of which
      #            the user's scoping rules will be applied
      # @return [Collection] resulting collection from applying all
      #                      user's roles scoping rules
      def apply_authz_scopes(on:)
        ScopingManager.apply_scopes_for_user(on, authz_user)
      end
      # @public api ===============================================================

      private
      # @return [Boolean] whether authorization has been performed, i.e. whether
      #                   one {#authorize} or {#skip_authorization} has been called
      def authorization_performed?
        !!@_authorization_performed
      end

      # Returns true if the user has permission for the path
      # and :using instance given as arguments
      #
      # @param path: path or url that will be checked
      # @param method: of the path or url
      # @param using: instance that will be used to determine authorization
      # @param skip_scoping: option to skip scoping validation
      # @return [Boolean]
      def authorized_path?(path, method: :get, using: nil, skip_scoping: false)
        recognized_ca = Rails.application.routes.recognize_path path,
                                                                method: method
        controller_name = recognized_ca[:controller]
        action_name = recognized_ca[:action]
        authorized?(controller: controller_name,
                    action: action_name,
                    using: using,
                    skip_scoping: skip_scoping)
      end

      included do |includer|
        includer.helper_method :authorized_path?
        includer.helper_method :apply_authz_scopes
        includer.helper Authz::Helpers::ViewHelpers
        includer.helper_method :authz_user
      end

    end
  end
end

