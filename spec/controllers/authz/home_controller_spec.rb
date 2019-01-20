module Authz
  describe HomeController, type: :controller do
    login_user
    routes { Authz::Engine.routes }

    describe 'index' do
      it 'should reject unauthorized users' do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        bypass_rescue # ignore rescue_from and raise
        expect {
          get :index
        }.to raise_error Authz::Controllers::AuthorizationManager::NotAuthorized
      end
    end

  end
end

