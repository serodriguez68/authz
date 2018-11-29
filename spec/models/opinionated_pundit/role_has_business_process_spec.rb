module OpinionatedPundit
  RSpec.describe RoleHasBusinessProcess, type: :model do
    describe 'Associations' do
      it { should belong_to(:business_process) }
      it { should belong_to(:role) }
    end

    describe 'validations' do
      it { should validate_presence_of(:business_process).with_message(:required) }
      it { should validate_presence_of(:role).with_message(:required) }
      it do
        rhbp = create(:opinionated_pundit_role_has_business_process)
        expect(rhbp).to validate_uniqueness_of(:opinionated_pundit_business_process_id).scoped_to(:opinionated_pundit_role_id)
      end
    end
  end
end
