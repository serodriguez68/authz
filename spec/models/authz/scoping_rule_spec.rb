module Authz
  RSpec.describe ScopingRule, type: :model do


    before(:each) do
      # Setup a dummy scopable
      module (self.class)::ScopableByTest
        extend Authz::Scopables::Base
        def self.available_keywords
          ['valid_keyword']
        end
      end
      @test_scopable = (self.class)::ScopableByTest
      allow(Scopables::Base).to receive(:get_scopables_names).and_return([@test_scopable.name])
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of :scopable }
      it { should validate_presence_of(:role).with_message(:required) }
      it { is_expected.to validate_presence_of :keyword }
      it do
        rule = create(:authz_scoping_rule)
        expect(rule).to validate_uniqueness_of(:scopable).scoped_to(:authz_role_id)
      end

      it 'should allow valid scopables' do
        should allow_value(@test_scopable.name).for(:scopable)
      end

      it 'should not allow invalid scopables' do
        should_not allow_value('ScopableByInvalid').for(:scopable)
      end


      describe 'of keyword' do
        let(:rule) { described_class.new(scopable: @test_scopable.name, authz_role_id: 1) }
        it 'should allow valid keywords' do
          expect(rule).to allow_value('valid_keyword').for(:keyword)
        end

        it 'should not allow invalid keywords' do
          expect(rule).not_to allow_value('invalid').for(:keyword)
        end
      end
    end

    describe 'associations' do
      it { should belong_to(:role) }
    end

  end
end
