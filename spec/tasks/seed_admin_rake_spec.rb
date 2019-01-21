# Rake.application.rake_require "tasks/seed_admin"

describe 'rake authz:seed_admin', type: :task do
  let(:support_module) { Authz::SeedAdmin }
  # required due to load order of rake tasks in rspec

  describe 'Authz::SeedAdmin' do
    
    describe '.create_controller_actions!' do
      let(:rcas) { Authz::ControllerAction.engine_reachable_controller_actions }
      it 'should create records for all of the library\'s internal controller actions' do
        expected_num = rcas.values.flatten.size
        created = support_module.create_controller_actions!
        expect(created.size).to eq expected_num
      end

      it 'should raise when a controller action has already been taken' do
        con = rcas.first.first
        act = rcas.first.second.first
        Authz::ControllerAction.create!(controller: con, action: act)
        expect {
          support_module.create_controller_actions!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    
    describe '.create_manage_auth_business_process!' do
      it 'should return a business process' do
        expect(support_module.create_manage_auth_business_process!).to(
          be_an_instance_of(Authz::BusinessProcess)
        )
      end
    end

    describe '.grant_controller_actions_to_business_process!' do
      let(:ca1) { create(:authz_controller_action) }
      let(:ca2) { create(:authz_controller_action) }
      let(:cas) { [ca1, ca2] }
      let(:bp)  { create(:authz_business_process) }

      it 'should associate the business process with the controller actions' do
        support_module.grant_controller_actions_to_business_process!(bp, cas)
        expect(bp.controller_actions).to match_array cas
      end

      it 'should rails if association fails' do
        expect{
          support_module.grant_controller_actions_to_business_process!(bp, [ca1, ca2, ca1])
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    
    describe '.run!' do
      it 'should return a business process' do
        expect(support_module.run!).to(
          be_an_instance_of(Authz::BusinessProcess)
        )
      end

      it 'should not create anything is something fails ' do
        allow(support_module).to(
          receive(:grant_controller_actions_to_business_process!)
        ).and_raise('boom')
        start = Authz::ControllerAction.all.size
        expect {
          support_module.run!
        }.to raise_error RuntimeError
        expect(Authz::ControllerAction.all.size).to eq start
      end

    end
  end

  describe 'execution of task' do

    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include "environment"
    end

    it 'calls SeedAdmin.run!' do
      expect(support_module).to receive(:run!).once.and_call_original
      task.execute
    end

    it 'should run gracefully on a clean DB' do
      expect { task.execute }.not_to raise_error
    end

  end
end