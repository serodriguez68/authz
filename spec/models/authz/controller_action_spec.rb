module Authz
  describe ControllerAction, type: :model do

    describe 'Validations' do
      it { is_expected.to validate_presence_of :controller }
      it { is_expected.to validate_presence_of :action }
      it { is_expected.to validate_uniqueness_of(:controller).scoped_to(:action) }

      it 'should be valid when instantiated with a correct controller and action' do

        controller_action =  build(:authz_controller_action, controller: 'visitors', action: 'index')
        expect(controller_action).to be_valid
      end

      it 'should be valid when instantiated with a non-existent controller and action' do
        controller_action = build(:authz_controller_action, controller: 'foo', action: 'bar')
        expect(controller_action).to be_invalid
      end

    end

    describe 'Class Methods' do

      it 'should return the reachable controller actions according to the routes' do
        # This will overwrite the routes file
        Rails.application.routes.draw do
          resources :cities, only: [:new, :create]
        end
        expected_result = { 'cities' => ['create', 'new'] } # Actions have order dependency
        result = described_class.reachable_controller_actions
        expect(result).to eq(expected_result)
        # This is a horrible hack to force rails to reload the routes that were
        # overwritten at the beginning of this test
        Rails.application.reload_routes!
      end

    end

    describe 'Associations' do
      it { should have_many(:business_process_has_controller_actions) }
      it { should have_many(:business_processes).through(:business_process_has_controller_actions) }
      it { should have_many(:roles).through(:business_processes) }
      it { should have_many(:role_grants).through(:roles) }
      it { should have_many(:users) }
    end

  end
end
