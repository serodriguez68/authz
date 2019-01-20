module Authz
  describe Authz::ApplicationController, type: :controller do

    controller(Authz::ApplicationController) do
      def custom
        render plain: 'ok'
      end
    end

    before(:each) do
      routes.draw { get "custom" => "authz/application#custom" }

      # FIXME: For some reason devise is not loading correctly
      # and DeviseController is not defined, so wer are forced to
      # stub out this method
      allow(controller).to receive(:devise_controller?).and_return(false)
    end

    it 'should force authentication on all controller actions' do
      # Setup
      # Make sure that even if the main_app's application controller does
      # not force authentication, Authz::Application controller does force
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:authorization_performed?).and_return(true)
      # Execute
      expect(Authz).to receive(:force_authentication_method).and_return(:to_s)
      get :custom
    end

    it 'should force verify authorization on all controller actions' do
      # Setup
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      sign_in user
      allow(controller).to receive(:authenticate_authz_user).and_return(true)
      # Execute
      expect(controller).to receive(:verify_authorized).and_return(true)
      get :custom
    end

  end
end

