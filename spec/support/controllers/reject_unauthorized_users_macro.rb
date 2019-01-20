module RejectUnauthorizedUsersMacro

  def test_unauthorized_access(action_verb_map)
    instance_eval <<-END_EVAL, __FILE__, __LINE__ + 1
      describe 'when an unauthorized user tries to access' do
        login_user
        routes { Authz::Engine.routes }

        action_verb_map.each do |action, verb|
          it action.to_s + ', it should be rejected' do
            # Setup
            allow(controller).to receive(:authenticate_user!).and_return(true)
            bypass_rescue # ignore rescue_from and raise
            # Test
            expect {
              send(verb, action, params: {id: 1})
            }.to raise_error Authz::Controllers::AuthorizationManager::NotAuthorized
          end
        end
      end
    END_EVAL
  end

end

RSpec.configure do |config|
  config.extend RejectUnauthorizedUsersMacro, type: :controller
end