module Authz
  module Controllers
    describe ScopingManager do

      describe '.has_access_to_instance?' do

        before(:each) do
          @usr = create(:user)
          @role = create(:authz_role)
          @usr.roles << @role
          @city1 = create(:city)
          @city2 = create(:city)
          @clrnc1 = create(:clearance, level: 1)
          @clrnc2 = create(:clearance, level: 2)
          @report = create(:report, city: @city1, clearance: @clrnc1)
        end

        it 'should return true when instance falls within scope of all scopables' do
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                                      role: @role,
                                      keyword: @city1.name)
          create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                                      role: @role,
                                      keyword: @clrnc1.name)

          expect(
            described_class.has_access_to_instance?(@role, @report, @usr)
          ).to eq true
        end

        it 'should return false when instance falls out of scope of one or more scopables' do
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                 role: @role,
                 keyword: @city2.name)
          create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                 role: @role,
                 keyword: @clrnc1.name)

          expect(
            described_class.has_access_to_instance?(@role, @report, @usr)
          ).to eq false
        end

        it 'should raise a RecordNotFound exception when the role has incomplete rule definitions' do
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                 role: @role,
                 keyword: @city1.name)

          expect{
            described_class.has_access_to_instance?(@role, @report, @usr)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'should call Authz::Scopable::Base.get_applicable_scopables!' do
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                                      role: @role,
                                      keyword: @city1.name)
          create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                                      role: @role,
                                      keyword: @clrnc1.name)
          expect(Authz::Scopables::Base).to(
            receive(:get_applicable_scopables!).with(@report.class)
              .and_call_original
          )

          described_class.has_access_to_instance?(@role, @report, @usr)
        end

      end
    end
  end
end
