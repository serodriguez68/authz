module Authz
  RSpec.describe RoleGrant, type: :model do

    describe 'DB indexes' do
      it 'should have a composite unique index on rolable_type_rolable_id_role_id' do
        expect(
          ActiveRecord::Migration.index_exists?(described_class.table_name,
                                                [:rolable_type, :rolable_id, :authz_role_id],
                                                unique: true)
        ).to be true
      end
    end

    describe 'Associations' do
      it { should belong_to(:role) }
      it { should belong_to(:rolable) }
    end

    describe 'validations' do
      it { should validate_presence_of(:rolable).with_message(:required) }
      it { should validate_presence_of(:role).with_message(:required) }
      it do
        rg = create(:authz_role_grant)
        expect(rg).to validate_uniqueness_of(:authz_role_id).scoped_to([:rolable_type, :rolable_id])
      end
    end

  end
end
