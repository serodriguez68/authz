module Authz
  describe HomeController, type: :controller do
    test_unauthorized_access(
      index: :get
    )
  end
end

