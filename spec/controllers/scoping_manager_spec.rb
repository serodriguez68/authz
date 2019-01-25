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

        it 'should call role#cached_granted_keyword_for to get the applicable keyword' do
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                 role: @role,
                 keyword: @city1.name)
          create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                 role: @role,
                 keyword: @clrnc1.name)
          expect(@role).to(
            receive(:cached_granted_keyword_for).twice
              .and_call_original
          )

          described_class.has_access_to_instance?(@role, @report, @usr)
        end

      end

      describe '.apply_role_scopes' do
        before(:each) do
          @usr = create(:user)
          @role = create(:authz_role)
          @usr.roles << @role
          @city1 = create(:city)
          @city2 = create(:city)
          @clrnc1 = create(:clearance, level: 1)
          @clrnc2 = create(:clearance, level: 2)
          @in_report = create(:report, city: @city1,
                                       clearance: @clrnc1)
          @out_report1 = create(:report, city: @city2, clearance: @clrnc1)
          @out_report2 = create(:report, city: @city1, clearance: @clrnc2)
          @out_report3 = create(:report, city: @city2, clearance: @clrnc2)
        end

        let(:sb_city_rule) {
          create(:authz_scoping_rule, scopable: 'ScopableByCity',
                 role: @role,
                 keyword: @city1.name)
        }

        let(:sb_clearance_rule) {
          create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                 role: @role,
                 keyword: @clrnc1.name)
        }

        it 'should call Authz::Scopable::Base.get_applicable_scopables!' do
          sb_city_rule
          sb_clearance_rule
          expect(Authz::Scopables::Base).to(
            receive(:get_applicable_scopables!).with(Report)
              .and_call_original
          )

          described_class.apply_role_scopes(@role, Report, @usr)
        end

        it 'should call role#cached_granted_keyword_for to get the applicable keyword' do
          sb_city_rule
          sb_clearance_rule
          expect(@role).to(
            receive(:cached_granted_keyword_for).twice
              .and_call_original
          )

          described_class.apply_role_scopes(@role, Report, @usr)
        end

        it 'should raise a RecordNotFound exception when the role has incomplete rule definitions' do
          sb_city_rule
          expect {
            described_class.apply_role_scopes(@role, Report, @usr)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'should return the ANDing of all applicable scoping rules' do
          sb_city_rule
          sb_clearance_rule
          expect(
            described_class.apply_role_scopes(@role, Report, @usr)
          ).to match_array Report.where(id: @in_report.id)
        end

        it 'should not return records outside the scope of the role' do
          sb_city_rule
          sb_clearance_rule
          expect(
            described_class.apply_role_scopes(@role, Report, @usr)
          ).not_to include @out_report1
          expect(
            described_class.apply_role_scopes(@role, Report, @usr)
          ).not_to include @out_report2
          expect(
            described_class.apply_role_scopes(@role, Report, @usr)
          ).not_to include @out_report3
        end
      end

      describe '.apply_scopes_for_user' do
        context 'when the user has no roles' do
          it 'should return an empty collection' do
            usr = create(:user)
            create(:report)
            expect(Report.all.size).not_to eq 0
            expect(
              described_class.apply_scopes_for_user(Report, usr).size
            ).to eq 0
          end
        end

        context 'when the user has roles' do

          before(:each) do
            @usr = create(:user)
            @role1 = create(:authz_role)
            @role2 = create(:authz_role)
            @usr.roles << [@role1, @role2]
            @city1 = create(:city)
            @city2 = create(:city)
            @clrnc1 = create(:clearance, level: 1)
            @clrnc2 = create(:clearance, level: 2)
            @report1 = create(:report, city: @city1, clearance: @clrnc1)
            @report2 = create(:report, city: @city2, clearance: @clrnc2)
            @report3 = create(:report, city: @city2, clearance: @clrnc1)
            @report4 = create(:report, city: @city1, clearance: @clrnc2)
          end


          it 'should return the ORing (union) of the applicable role scopes' do
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                   role: @role1,
                   keyword: @city1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                   role: @role1,
                   keyword: @clrnc1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                   role: @role2,
                   keyword: @city2.name)
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                   role: @role2,
                   keyword: @clrnc2.name)
            expected = Report.where(id: [@report1.id, @report2.id])
            expect(
              described_class.apply_scopes_for_user(Report, @usr)
            ).to match_array expected
          end

          it 'should not return records outside the scope' do
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                   role: @role1,
                   keyword: @city1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                   role: @role1,
                   keyword: @clrnc1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                   role: @role2,
                   keyword: @city2.name)
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                   role: @role2,
                   keyword: @clrnc2.name)
            expect(
              described_class.apply_scopes_for_user(Report, @usr)
            ).not_to include @report3
            expect(
              described_class.apply_scopes_for_user(Report, @usr)
            ).not_to include @report4
          end

          it 'should tolerate one role having a scoping rule "All" while other rules have regular keywords' do
            # Test to make sure that the following error is not present
            # Relation passed to #or must be structurally compatible. Incompatible values: [:joins]
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                                        role: @role1,
                                        keyword: @city1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                                        role: @role1,
                                        keyword: @clrnc1.name)
            create(:authz_scoping_rule, scopable: 'ScopableByCity',
                                        role: @role2,
                                        keyword: 'All')
            create(:authz_scoping_rule, scopable: 'ScopableByClearance',
                                        role: @role2,
                                        keyword: @clrnc2.name)
            expected = Report.where(id: [@report1.id, @report2.id, @report4.id])
            expect(
              described_class.apply_scopes_for_user(Report, @usr)
            ).to match_array expected
          end
        end
      end

    end
  end
end
