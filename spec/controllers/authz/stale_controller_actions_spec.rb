module Authz
  describe PendingControllerActionsController, type: :controller do
    test_unauthorized_access(
      index: :get
    )
  end
end