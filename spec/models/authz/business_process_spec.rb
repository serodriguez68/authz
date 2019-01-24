module Authz
  RSpec.describe BusinessProcess, type: :model do
    describe 'validations' do
      it { is_expected.to validate_presence_of :code }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_uniqueness_of(:code) }
      it { is_expected.to validate_uniqueness_of(:name) }
      it { should allow_value('valid').for(:code) }
      it { should allow_value('valid_code').for(:code) }
      it { should_not allow_value('Invalid').for(:code) }
      it { should_not allow_value('9_a').for(:code) }

      it 'should automatically extract the code from the name' do
        bp = create(:authz_business_process, code: nil,
                                                          name: 'Manage Reports')
        expect(bp.code).to eq 'manage_reports'
      end
    end

    describe 'Associations' do
      it { should have_many(:business_process_has_controller_actions) }
      it { should have_many(:controller_actions).through(:business_process_has_controller_actions) }
      it { should have_many(:role_has_business_processes) }
      it { should have_many(:roles).through(:role_has_business_processes) }
      it { should have_many(:role_grants).through(:roles) }
      it { should have_many(:users) }
    end

    describe 'Callbacks' do
      describe 'touching associated roles' do
        before(:each) do
          @bp = create(:authz_business_process)
          @role = create(:authz_role)
          @bp.roles << @role
        end
        it 'should touch roles when touched' do
          expect {
            @bp.touch
          }.to change { @role.reload.updated_at }
        end

        it 'should touch roles when updated' do
          expect {
            @bp.update(name: 'foo')
          }.to change { @role.reload.updated_at }
        end
      end
    end


  end
end
