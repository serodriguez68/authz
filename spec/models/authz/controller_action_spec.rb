module Authz
  describe ControllerAction, type: :model do

    describe 'DB indexes' do
      it 'should have a composite controller+action index' do
        expect(
          ActiveRecord::Migration.index_exists?(described_class.table_name, [:controller, :action], unique: true)
        ).to be true
      end
    end

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

      it 'should be invalid when instantiated with a non-existent controller and action' do
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

      describe '.pending'  do
        context 'when some reachable controller actions have not been created in the DB' do
          it 'should return an array of controller action instances that are pending' do
            expect(described_class).to receive(:reachable_controller_actions).twice.and_return(
              { "tests" => %w(index new create) }
            )
            create(:authz_controller_action, controller: 'tests', action: 'index')

            expected_result = [described_class.new(controller: 'tests', action: 'new'),
                               described_class.new(controller: 'tests', action: 'create')]
            result = described_class.pending
            expect(result.map(&:attributes)).to match_array(expected_result.map(&:attributes))
          end
        end

        context 'when the DB is up to date' do
          it 'should return an empty array' do
            expect(described_class).to receive(:reachable_controller_actions).twice.and_return(
              { "tests" => %w(index) }
            )
            create(:authz_controller_action, controller: 'tests', action: 'index')
            expect(described_class.pending).to match_array([])
          end
        end
      end

      describe '.create_all_pending!' do
        it 'should create all pending controller actions and return them' do
          expect(described_class).to(
            receive(:reachable_controller_actions).at_least(:once)
              .and_return({'tests' => %w(new create)})
          )
          pending_cas = described_class.pending
          before_count = described_class.all.size
          returned = described_class.create_all_pending!
          after_count = described_class.all.size
          cas_created = after_count - before_count
          expect(returned.map{ |ca| [ca.controller, ca.action]}).to(
            match_array(pending_cas.map{ |ca| [ca.controller, ca.action]})
          )
          expect(cas_created).to eq pending_cas.size
        end

        it 'should not create any controller action if one fails' do
          expect(described_class).to(
            receive(:reachable_controller_actions).at_least(:once)
              .and_return({'tests' => %w(new create)})
          )

          expect(described_class).to(
            receive(:pending).at_least(:once)
              .and_return(
                [described_class.new(controller: 'tests', action: 'new'),
                 described_class.new(controller: 'tests', action: 'fail')]  # The CA that fails
              )
          )

          before_count = described_class.all.size
          expect{
            described_class.create_all_pending!
          }.to raise_error(ActiveRecord::RecordInvalid)
          after_count = described_class.all.size
          cas_created = after_count - before_count
          expect(cas_created).to eq 0
        end

        it 'should do nothing if there are no pending controller actions' do
          pending_cas = []
          expect(described_class).to(
            receive(:pending).at_least(:once).and_return(pending_cas)
          )
          expect{described_class.create_all_pending!}.not_to change{described_class.all.size}
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


    describe 'Instance methods' do
      describe '#description' do
        let(:ca) { create(:authz_controller_action) }
        let(:metadata_service) { Authz.metadata_service }
        let(:description) { 'foo' }
        it 'should call the configured metadata service to retrieve the description' do
          expect(metadata_service).to(
            receive(:get_controller_action_description)
              .with(ca.controller, ca.action).and_return(description)
          )
          expect(ca.description).to eq description
        end
      end
    end

  end
end

