module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      sign_in user
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  # FIXME: For some reason devise is not loading correctly
  # So we are forced to include this where it is supposed to go
  config.before(:all, type: :controller) do
    ::ApplicationController.include Devise::Controllers::Helpers
  end
end