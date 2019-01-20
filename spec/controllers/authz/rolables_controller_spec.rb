module Authz
  describe RolablesController, type: :controller do
    test_unauthorized_access(
      index: :get,
      show: :get,
      edit: :get,
      update: :patch
    )
  end
end