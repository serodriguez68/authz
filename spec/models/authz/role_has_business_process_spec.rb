module Authz
  RSpec.describe RoleHasBusinessProcess, type: :model do
    describe 'Associations' do
      it { should belong_to(:business_process) }
      it { should belong_to(:role) }
    end

    describe 'validations' do
      xit { should validate_presence_of(:business_process).with_message(:required) }
      xit { should validate_presence_of(:role).with_message(:required) }
      it do
        rhbp = create(:authz_role_has_business_process)
        expect(rhbp).to validate_uniqueness_of(:authz_business_process_id).scoped_to(:authz_role_id)
      end
    end
  end
end
