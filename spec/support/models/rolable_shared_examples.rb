RSpec.shared_examples 'rolable' do

  describe 'associations' do
    it { should have_many(:role_grants) }
    it { should have_many(:roles).through(:role_grants) }
    it { should have_many(:business_processes).through(:roles) }
    it { should have_many(:controller_actions).through(:business_processes) }
    it { should have_many(:scoping_rules).through(:roles) }
  end
  
  describe '#authz_label' do
    it 'should have a default behaviour' do
      allow(Authz).to receive(:register_rolable)
      class (self.class)::Test < ApplicationRecord
        self.table_name = 'users'
        include Authz::Models::Rolable
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
          self.table_name = 'users'
          include Authz::Models::Rolable
          def foo; 'bar' end
        end
        klass = (self.class)::Test

        klass.authz_label_method :foo
        instance = klass.new
        expect(instance.authz_label).to eq 'bar'
      end
    end
  end

  describe '#roles_cache_key' do
    let(:user) { create(:user) }
    let(:r1) { create(:authz_role) }
    let(:r2) { create(:authz_role) }
    it 'should create composite key using each of the roles cache keys' do
      user.roles << [r1, r2]
      expect(user.roles_cache_key).to include(r1.cache_key).and include(r2.cache_key)
    end

  end

end