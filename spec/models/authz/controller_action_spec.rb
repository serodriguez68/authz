module Authz
  describe ControllerAction, type: :model do

    describe 'Validations' do
      it { is_expected.to validate_presence_of :controller }
      it { is_expected.to validate_presence_of :action }
      it { is_expected.to validate_uniqueness_of(:controller).scoped_to(:action) }

      it 'should be valid when instantiated with a correct controller and action' do
        # This will overwrite the routes file
        Rails.application.routes.draw do
          resources :foos, only: [:new]
        end

        controller_action =  build(:authz_controller_action, controller: 'foos', action: 'new')
        expect(controller_action).to be_valid

        # This is a horrible hack to force rails to reload the routes that were
        # overwritten at the beginning of this test
        Rails.application.reload_routes!
      end

      it 'should be valid when instantiated with a non-existent controller and action' do
        controller_action = build(:authz_controller_action, controller: 'foo', action: 'bar')
        expect(controller_action).to be_invalid
      end

    end

    describe 'Class Methods' do

      describe '.reachable_controller_actions' do
        it 'should return the combined reachable controller actions from the engine and the main app' do
          allow(described_class).to(
            receive(:main_app_reachable_controller_actions)
          ).and_return(
             {'cities' => ['create', 'new'], 'authz/rolables' => ['bar']}
          )

          allow(described_class).to(
            receive(:engine_reachable_controller_actions)
          ).and_return(
            {'authz/roles' => ['new'], 'authz/rolables' => ['index']}
          )

          expected_result = {
            'cities' => ['create', 'new'],
            'authz/roles' => ['new'],
             'authz/rolables' => ['bar', 'index']
          }

          result = described_class.reachable_controller_actions
          expect(result).to include(expected_result)
        end
      end

      describe '.main_app_reachable_controller_actions' do
        it 'should return the reachable controller actions declared on the main app router' do
          # This will overwrite the routes file
          Rails.application.routes.draw do
            resources :cities, only: [:new, :create]
          end
          expected_result = { 'cities' => ['create', 'new'] } # Actions have order dependency
          result = described_class.main_app_reachable_controller_actions
          expect(result).to eq(expected_result)
          # This is a horrible hack to force rails to reload the routes that were
          # overwritten at the beginning of this test
          Rails.application.reload_routes!
        end
      end

      describe '.engine_reachable_controller_actions' do
        it 'should return the reachable controller actions declared on the engine router' do
          # This will overwrite the routes file
          Authz::Engine.routes.draw do
            resources :groups, only: [:new, :create]
          end
          expected_result = { 'authz/groups' => ['create', 'new'] } # Actions have order dependency
          result = described_class.engine_reachable_controller_actions
          expect(result).to eq(expected_result)
          # This is a horrible hack to force rails to reload the routes that were
          # overwritten at the beginning of this test
          Rails.application.reload_routes!
        end
      end

    end

    describe 'Associations' do
      it { should have_many(:business_process_has_controller_actions) }
      it { should have_many(:business_processes).through(:business_process_has_controller_actions) }
      it { should have_many(:roles).through(:business_processes) }
      it { should have_many(:role_grants).through(:roles) }
      it { should have_many(:users) }
    end

    describe 'Callbacks' do
      describe '#touch_upstream_instances' do
        it 'should touch all upstream associated models' do
          ca = create(:authz_controller_action)
          ca2 = build(:authz_controller_action)
          create_list(:authz_business_process_has_controller_action, 2, controller_action: ca)
          bphcas = ca.business_process_has_controller_actions
          bps = ca.business_processes
          create_list(:authz_role_has_business_process, 2, business_process: bps.first)
          create_list(:authz_role_has_business_process, 2, business_process: bps.last)
          roles = ca.roles

          aggregate_failures 'upstream models' do
            expect{
              ca.update(controller: ca2.controller, action: ca2.action)
            }.to change { bphcas.pluck(:updated_at) }

            expect{
              ca.update(controller: ca2.controller, action: ca2.action)
            }.to change { bps.pluck(:updated_at) }

            expect{
              ca.update(controller: ca2.controller, action: ca2.action)
            }.to change { roles.pluck(:updated_at) }
          end
        end
      end

    end

  end
end

