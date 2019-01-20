module Authz
  describe ControllerActionsController, type: :controller do
    test_unauthorized_access(
      index: :get,
      show: :get,
      new: :get,
      create: :post,
      edit: :get,
      update: :patch,
      destroy: :delete
    )
  end
end