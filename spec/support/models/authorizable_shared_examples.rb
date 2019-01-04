RSpec.shared_examples "authorizable" do

  describe 'associations' do
    it { should have_many(:role_grants) }
    it { should have_many(:roles).through(:role_grants) }
    it { should have_many(:business_processes).through(:roles) }
    it { should have_many(:controller_actions).through(:business_processes) }
    it { should have_many(:scoping_rules).through(:roles) }
  end

  describe '.register_in_authorization_admin' do
    it 'should call Authz.register_authorizable_in_admin' do
      expect(Authz).to receive(:register_authorizable_in_admin).with(described_class, :foo)
      described_class.register_in_authorization_admin(identifier: :foo)
    end
  end

end