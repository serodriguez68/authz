module Authz
  RSpec.describe RoleHasBusinessProcess, type: :model do
    describe 'Associations' do
      it { should belong_to(:business_process) }
      it { should belong_to(:role).touch(true) }
    end

    describe 'validations' do
      it { should validate_presence_of(:business_process).with_message(:required) }
      it { should validate_presence_of(:role).with_message(:required) }
      it do
        rhbp = create(:authz_role_has_business_process)
        expect(rhbp).to validate_uniqueness_of(:authz_business_process_id).scoped_to(:authz_role_id)
      end
    end

    describe 'Callbacks' do
      describe 'touching role' do
        let(:role) { create(:authz_role) }
        let(:rhbp) { create(:authz_role_has_business_process, role: role) }

        it 'should touch role when created' do
          expect{
            rhbp
          }.to change{ role.reload.updated_at }
        end

        it 'should touch role when destroyed' do
          rhbp
          expect{
            rhbp.destroy
          }.to change{ role.reload.updated_at }
        end
      end
    end

  end
end
