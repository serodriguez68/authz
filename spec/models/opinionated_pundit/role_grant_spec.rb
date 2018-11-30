module OpinionatedPundit
  RSpec.describe RoleGrant, type: :model do
    describe 'Associations' do
      it { should belong_to(:role) }
      it { should belong_to(:rolable) }
    end

    describe 'validations' do
      it { should validate_presence_of(:rolable).with_message(:required) }
      it { should validate_presence_of(:role).with_message(:required) }
      it do
        rg = create(:opinionated_pundit_role_grant)
        expect(rg).to validate_uniqueness_of(:opinionated_pundit_role_id).scoped_to([:rolable_type, :rolable_id])
      end
    end

  end
end
