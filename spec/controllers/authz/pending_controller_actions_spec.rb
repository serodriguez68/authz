module Authz
  describe StaleControllerActionsController, type: :controller do
    test_unauthorized_access(
      index: :get
    )
  end
end