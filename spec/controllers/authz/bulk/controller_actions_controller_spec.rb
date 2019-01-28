module Authz
  module Bulk
    RSpec.describe ControllerActionsController, type: :controller do
      test_unauthorized_access(
        create: :post,
        destroy: :delete
      )
    end
  end
end
