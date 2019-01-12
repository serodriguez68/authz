RSpec.shared_examples "authorizable" do

  describe 'associations' do
    it { should have_many(:role_grants) }
    it { should have_many(:roles).through(:role_grants) }
    it { should have_many(:business_processes).through(:roles) }
    it { should have_many(:controller_actions).through(:business_processes) }
  end

  describe 'controller action clearance checking' do
    let!(:authorizable) { create(:user) }
    let!(:r) {create :authz_role}
    let!(:bp) {create :authz_business_process}
    let!(:ca) {create :authz_controller_action}
    let!(:bphca) {create :authz_business_process_has_controller_action,
                   controller_action: ca, business_process: bp}
    let!(:rhpb) {create :authz_role_has_business_process,
                  business_process: bp, role: r}
    let!(:rg) {create :authz_role_grant, role: r, rolable: authorizable}

    it 'should have clearance for an assigned controller action' do
      clearance = authorizable.clear_for?(controller: ca.controller, action: ca.action)
      expect(clearance).to be true
    end

    it 'should not have clearance for an unassigned controller action' do
      clearance = authorizable.clear_for?(controller: ca.controller, action: "#{ca.action}_foo")
      expect(clearance).to be false
    end

  end

  describe '.register_in_authorization_admin' do
    it 'should call Authz.register_authorizable_in_admin' do
      expect(Authz).to receive(:register_authorizable_in_admin).with(described_class, :foo)
      described_class.register_in_authorization_admin(identifier: :foo)
    end
  end
  
  describe '#authz_label' do
    it 'should have a default behaviour' do
      allow(Authz).to receive(:register_rolable)
      class (self.class)::Test < ApplicationRecord
        self.table_name = "users"
        include Authz::Models::Authorizable
        def name; 'foo' end
      end
      klass = (self.class)::Test

      instance = klass.new
      expect(instance.authz_label).to eq 'foo'
    end

    context 'when overriden with .authz_label_method' do
      it 'should modify the #authz_label behaviour' do
        allow(Authz).to receive(:register_rolable)
        class (self.class)::Test < ApplicationRecord
          self.table_name = "users"
          include Authz::Models::Authorizable
          def foo; 'bar' end
        end
        klass = (self.class)::Test

        klass.authz_label_method :foo
        instance = klass.new
        expect(instance.authz_label).to eq 'bar'
      end
    end
  end

end