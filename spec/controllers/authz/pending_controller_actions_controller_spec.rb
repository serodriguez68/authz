require 'rails_helper'

module Authz
  RSpec.describe PendingControllerActionsController, type: :controller do

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

  end
end
