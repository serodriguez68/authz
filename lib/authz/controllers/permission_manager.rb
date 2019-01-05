module Authz
  module Controllers
    module PermissionManager
      def self.has_permission?(role, controller_name, action_name)
        role.controller_actions.exists?(controller: controller_name,
                                        action: action_name)
      end
    end
  end
end
