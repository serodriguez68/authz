module Authz
  module Scopables
    describe Base do

      describe '.register_scopable' do
        context "when a module extends #{described_class}" do
          it 'should get registered as a scopable' do
            expect(described_class).to receive(:register_scopable)
            module (self.class)::ScopableByTest
              extend Authz::Scopables::Base
            end
          end
        end
      end

      describe '.get_scopables_names' do
        it 'should return the stringified name of all scoping modules' do
          module (self.class)::ScopableByTest
            extend Authz::Scopables::Base
          end
          testing_module = (self.class)::ScopableByTest
          expect(described_class.get_scopables_names).to include(testing_module.name)
        end
      end

      describe '.get_scopables_modules' do
        it 'should return the handle to all scoping modules' do
          module (self.class)::ScopableByTest
            extend Authz::Scopables::Base
          end
          testing_module = (self.class)::ScopableByTest
          expect(described_class.get_scopables_modules).to include(testing_module)
        end
      end

      describe '.scopable_exists?' do
        before(:each) do
          allow(described_class).to receive(:get_scopables_names).and_return(['ScopableByTest'])
        end

        it 'should return true when given an existing scopable' do
          expect(described_class.scopable_exists?('ScopableByTest')).to be(true)
        end

        it 'should return false when given an unexisting scopable' do
          expect(described_class.scopable_exists?('Foo')).to be(false)
        end
      end

      describe '.normalize_if_special_keyword' do
        before(:each) do
          module (self.class)::ScopableByTest
            extend Authz::Scopables::Base
          end
          @scopable = (self.class)::ScopableByTest
        end
        it 'should normalize the special keyword "all"' do
          expect(@scopable.normalize_if_special_keyword('all')).to eq :all
          expect(@scopable.normalize_if_special_keyword('AlL')).to eq :all
          expect(@scopable.normalize_if_special_keyword(:All)).to eq :all
          expect(@scopable.normalize_if_special_keyword(:all)).to eq :all
        end
        it 'should leave any non special keywords untouched' do
          expect(@scopable.normalize_if_special_keyword('other')).to eq 'other'
          expect(@scopable.normalize_if_special_keyword(:other)).to eq :other
        end
      end

      describe '.scopable_by?' do
        it 'should return true when class includes scopable' do
          klass = self.class
          class klass::ScopedClass < ApplicationRecord
            include ScopableByTestCity
          end
          expect(described_class.scopable_by? klass::ScopedClass, ScopableByTestCity).to be true
        end

        it 'should return false when class does not include scopable' do
          klass = self.class
          class klass::UnscopedClass < ApplicationRecord; end
          expect(described_class.scopable_by? klass::UnscopedClass, ScopableByTestCity).to be false
        end
      end

      describe 'inferred naming' do
        it 'should infer the scoping class name from the module name' do
          expect(ScopableByTestCity.scoping_class_name).to eq "TestCity"
        end

        it 'should infer the scoping class from the module name' do
          expect(ScopableByTestCity.scoping_class).to eq TestCity
        end

        it 'should return the correct singular and plural association names' do
          expect(ScopableByTestCity.singular_association_name).to eq :test_city
          expect(ScopableByTestCity.plural_association_name).to eq :test_cities
        end

        it 'should return the association method name in the correct format' do
          expect(ScopableByTestCity.association_method_name).to(
            eq 'scopable_by_test_city_association_name'
          )
        end

        it 'should return the "apply_scopable_method_name" in the correct format' do
          expect(ScopableByTestCity.apply_scopable_method_name).to(
            eq 'apply_scopable_by_test_city'
          )
        end
      end

      describe '.valid_keyword?' do
        it 'should return true when given a valid keyword' do
          expect(ScopableByTestCity.valid_keyword?('valid_keyword')).to be(true)
        end

        it 'should return false when given an invalid keyword' do
          expect(ScopableByTestCity.valid_keyword?('foo')).to be(false)
        end
      end

      describe '.scopable_by_test_city_association_name' do
        it 'should automatically infer the association name to use' do
          expect(ScopedClass.scopable_by_test_city_association_name).to eq :test_city
        end

        context 'when scoped class is ambiguous' do
          it 'should raise an error' do
            expect { AmbiguousScopedClass.scopable_by_test_city_association_name }.to raise_error(described_class::AmbiguousAssociationName)
          end
        end
      end

      describe '.set_scopable_by_test_city_association_name' do
        it 'should override the scopable_by_city_association_name method' do
          current_assoc_name = ScopedClass.scopable_by_test_city_association_name
          ScopedClass.set_scopable_by_test_city_association_name :foo
          expect(ScopedClass.scopable_by_test_city_association_name).to eq :foo
          ScopedClass.set_scopable_by_test_city_association_name current_assoc_name
        end
      end

      describe '.get_applicable_scopables' do
        it 'should return the scopable modules included in the class' do
          expect(
            described_class.get_applicable_scopables(Report)
          ).to match_array([ScopableByCity, ScopableByClearance])
        end
      end

      describe '.get_applicable_scopables!' do
        it 'should raise an error when no applicable scopables are found' do
          class (self.class)::Test; end
          klass = (self.class)::Test
          expect{
            described_class.get_applicable_scopables!(klass)
          }.to raise_error(described_class::NoApplicableScopables)
        end

        it 'should return the applicable scopables for a scoped class' do
          expect(
            described_class.get_applicable_scopables!(Report)
          ).to match_array([ScopableByCity, ScopableByClearance])
        end
      end

      describe '.apply_scopable_by_city' do
        context 'when the scoped class is equal to the scoping class' do
          it 'should return only the subset of cities according to the keyword' do
            keyword = 'inscope'
            in_scope = create(:city, name: keyword)
            out_scope = create(:city, name: 'outscope')

            expected = City.where(name: keyword)
            expect(City.apply_scopable_by_city(keyword, nil)).to match_array(expected)

          end
        end

        context 'when the scoped class is different from the scoping class' do

          before(:each) do
            @keyword = 'in_city'
            @in_city = create(:city, name: @keyword)
            out_city = create(:city, name: 'out_city')
            @clearance = create(:clearance, name: 'secret', level: 1)
            in_report = create(:report, city: @in_city, clearance: @clearance)
            out_report = create(:report, city: out_city, clearance: @clearance)
          end

          it 'should return only the subset of records according to scopable keyword' do
            expected = Report.where(city_id: @in_city.id)
            expect(Report.apply_scopable_by_city(@keyword, nil)).to match_array(expected)
          end

          it 'should return all when keyword is all' do
            keyword = :all
            expected = Report.all
            expect(Report.apply_scopable_by_city(keyword, nil)).to match_array(expected)
          end

          it 'should return records not associated with the scoping class when the keyword resolved ids contain nil' do
            orphan_report = create(:report, city: @in_city, clearance: @clearance)
            orphan_report.update_columns(city_id: nil)
            allow(ScopableByCity).to receive(:resolve_keyword!).and_return([@in_city.id, nil])

            expected = Report.where(city_id: [@in_city.id, nil])
            expect(Report.apply_scopable_by_city(@keyword, nil)).to match_array(expected)
          end
        end

        context 'when the scoped class is not associated with the scoping class' do
          it 'should raise a NoAssociationFound Error' do
            klass = self.class
            class klass::Test < ApplicationRecord
              include ScopableByCity
            end
            expect { klass::Test.apply_scopable_by_city('foo', nil) }.to raise_error(described_class::NoAssociationFound)
          end
        end

      end

      describe 'when multiple scopables are applied simultaneously' do
        it 'should return the subset that complies with all scopes' do
          in_city = create(:city, name: 'in_city')
          out_city = create(:city, name: 'out_city')
          in_clearance = create(:clearance, name: 'in_clearance', level: 1)
          out_clearance = create(:clearance, name: 'out_clearance', level: 2)

          create(:report, city: in_city, clearance: in_clearance)
          create(:report, city: in_city, clearance: out_clearance)
          create(:report, city: out_city, clearance: in_clearance)
          create(:report, city: out_city, clearance: out_clearance)

          expected = Report.where(city_id: in_city.id, clearance_id: in_clearance.id)
          expect(
                Report.apply_scopable_by_city('in_city', nil)
                      .apply_scopable_by_clearance('in_clearance', nil)
          ).to match_array(expected)

        end
      end

      describe '.associated_scoping_instances_ids' do
        context 'when the instance is associated with one instance of the scoping class' do
          it 'should correctly return the id of the associated scoping class instance' do
            in_city = create(:city, name: 'in_city')
            out_city = create(:city, name: 'out_city')
            in_clearance = create(:clearance, name: 'in_clearance', level: 1)
            out_clearance = create(:clearance, name: 'out_clearance', level: 2)

            report = create(:report, city: in_city, clearance: in_clearance)

            expect(ScopableByCity.associated_scoping_instances_ids(report)).to match_array([in_city.id])
            expect(ScopableByClearance.associated_scoping_instances_ids(report)).to match_array([in_clearance.id])
          end
        end

        context 'when the instance is associated with many instances of the scoping class' do
          it 'should correctly return the ids of the associated scoping class instances' do
            in_city1 = create :city
            in_city2 = create :city
            out_city = create :city
            ann = create :announcement
            ann.cities << [in_city1, in_city2]

            exp_arr = [in_city1, in_city2].map(&:id)
            expect(ScopableByCity.associated_scoping_instances_ids(ann)).to match_array(exp_arr)
          end
        end

        context 'when the instance is orphaned from the scoping class' do
          it 'should return an empty array when the association is singular (e.g report has no city)' do
            in_city = create(:city, name: 'in_city')
            clearance = create(:clearance, name: 'in_clearance', level: 1)

            report = create(:report, city: in_city, clearance: clearance)
            report.update_columns city_id: nil

            expect(ScopableByCity.associated_scoping_instances_ids(report)).to match_array([])
          end

          it 'should return an empty array when the association is plural (e.g. announcement is not available in any city)' do
            ann = create :announcement
            expect(ScopableByCity.associated_scoping_instances_ids(ann)).to match_array([])
          end
        end

        context 'when the class of the instance has a misconfigured association for the scopable' do
          it 'should raise an error warning the user about the misconfiguration' do
            report = create(:report)
            scoped_class = report.class
            assoc_method = scoped_class.send(ScopableByCity.association_method_name)
            allow(report).to receive(assoc_method).and_return(:foo)
            expect {
              ScopableByCity.associated_scoping_instances_ids(report)
            }.to raise_error(described_class::MisconfiguredAssociation)
          end
        end

        context 'when the instance to check is an instance of the scoping class (e.g. a city in ScopableByCity)' do
          it 'should return the id of the instance' do
            city1 = create :city
            city2 = create :city
            exp_arr = [city1.id]
            expect(ScopableByCity.associated_scoping_instances_ids(city1)).to match_array(exp_arr)
          end
        end
      end

      describe '.within_scope_of_keyword?' do
        context 'when the instance is associated with one instance of the scoping class' do

          before(:each) do
            @in_city  = create(:city, name: 'in_city')
            @out_city = create(:city, name: 'out_city')
            @report   = create(:report, city: @in_city)
          end

          it 'should return true for instances within scope of the keyword' do
            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([@in_city.id])
            )

            expect(
              ScopableByCity.within_scope_of_keyword?(@report,
                                                      'foo',
                                                      nil)
            ).to eq true
          end

          it 'should return false for instances outside of the scope of the keyword' do
            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([@out_city.id])
            )

            expect(
              ScopableByCity.within_scope_of_keyword?(@report,
                                                      'foo',
                                                      nil)
            ).to eq false
          end
        end

        context 'when the instance is associated with many instances of the scoping class' do
          it 'should return true when there is at least one scoping ' \
              'instance in common between the keyword and the tested ' \
              'instance' do
            city1 = create :city
            city2 = create :city
            city3 = create :city
            ann = create :announcement
            ann.cities << [city1, city2]

            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([city2.id, city3.id])
            )

            expect(
              ScopableByCity.within_scope_of_keyword?(ann,
                                                      'foo',
                                                      nil)
            ).to eq true
          end

          it 'should return false when there is no ' \
              'instance in common between the keyword and the tested ' \
              'instance' do
            city1 = create :city
            city2 = create :city
            city3 = create :city
            city4 = create :city
            ann = create :announcement
            ann.cities << [city1, city2]

            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([city3.id, city4.id])
            )

            expect(
              ScopableByCity.within_scope_of_keyword?(ann,
                                                      'foo',
                                                      nil)
            ).to eq false
          end
        end

        context 'when the instance is not associated with any instance of the scoping class' do
          before(:each) do
            @city = create :city
            @rep = create(:report)
            @rep.update_columns city_id: nil
          end
          it 'should return true when the resolved keyword includes nil' do
            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([@city.id, nil])
            )
            expect(
              ScopableByCity.within_scope_of_keyword?(@rep, 'foo', nil)
            ).to eq true
          end

          it 'should return false when the resolved keyword does not include nil' do
            allow(ScopableByCity).to(
              receive(:resolve_keyword!).and_return([@city.id])
            )
            expect(
              ScopableByCity.within_scope_of_keyword?(@rep, 'foo', nil)
            ).to eq false
          end

        end

        context 'when the instance is an instance of the scoping class' do
          # e.g. verifying the creation of a new city in ScopableByCity
          context 'when the instance has no id (it has not been persisted)' do
            let!(:old_city) { create(:city) }
            let(:new_city) { build :city }
            it 'should return true if the keyword is all' do
              kw = :all
              expect(
                ScopableByCity.within_scope_of_keyword?(new_city, kw, nil)
              ).to eq true
            end

            it 'should return false if the resolved keyword does not include nil' do
              allow(ScopableByCity).to(
                receive(:resolve_keyword!).and_return([old_city.id])
              )
              expect(
                ScopableByCity.within_scope_of_keyword?(new_city, 'foo', nil)
              ).to eq false
            end

            it 'should return false if the resolved keyword includes nil' do
              allow(ScopableByCity).to(
                receive(:resolve_keyword!).and_return([old_city.id, nil])
              )
              expect(
                ScopableByCity.within_scope_of_keyword?(new_city, 'foo', nil)
              ).to eq false
            end
          end
        end

      end

      describe '.resolve_keyword!' do
        it 'should return the result of .resolve_keyword when the result is valid' do
          kw = 'foo'
          requester = nil
          expected = [1, 2, 3]

          expect(ScopableByCity).to receive(:resolve_keyword).and_return(expected)
          expect(ScopableByCity.resolve_keyword!(kw, requester)).to match_array expected
        end

        it 'should raise an exception when the result of .resolve_keyword is invalid' do
          kw = 'foo'
          requester = create(:user)
          expected = nil # Invalid return value

          expect(ScopableByCity).to receive(:resolve_keyword).and_return(expected)
          expect{
            ScopableByCity.resolve_keyword!(kw, requester)
          }.to raise_error described_class::UnresolvableKeyword
        end

      end


    end
  end
end

