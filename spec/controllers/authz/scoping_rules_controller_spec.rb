module Authz
  describe ScopingRulesController, type: :controller do

    describe 'when an unauthorized user tries to access' do
      login_user
      routes { Authz::Engine.routes }

      action_verb_map = {
        new: :get,
        create: :post,
        edit: :get,
        update: :patch
      }

      action_verb_map.each do |action, verb|
        it action.to_s + ', it should be rejected' do
          # Setup
          allow(controller).to receive(:authenticate_user!).and_return(true)
          bypass_rescue # ignore rescue_from and raise
          # Test
          expect {
            send(verb, action, params: {role_id: 1, id: 4})
          }.to raise_error Authz::Controllers::AuthorizationManager::NotAuthorized
        end
      end
    end

  end
end