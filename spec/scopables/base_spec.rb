module Authz
  module Scopables
    describe Base do

      describe '.get_scopables_names' do
        it 'should return the stringified name of all scoping modules' do
          file_name = 'scopable_by_test_city'
          src = "spec/support/scopables/#{file_name}.rb"
          dst = "#{Authz.scopables_directory}/#{file_name}.rb"
          FileUtils.copy_file(src, dst)
          expect(described_class.get_scopables_names).to include(file_name.camelize)
          File.delete(dst)
        end
      end

      describe '.get_scopables_modules' do
        it 'should return the handle to all scoping modules' do
          file_name = 'scopable_by_test_city'
          src = "spec/support/scopables/#{file_name}.rb"
          dst = "#{Authz.scopables_directory}/#{file_name}.rb"
          FileUtils.copy_file(src, dst)

          scoping_class = file_name.camelize
          expect(described_class.get_scopables_modules).to include(scoping_class.constantize)

          File.delete(dst)
        end
      end

      context 'using ScopableByTestCity support file' do

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
      end

      context 'using the dummys models and scopables' do

        describe '.get_applicable_scopables' do
          it 'should return the scopable modules included in the class' do
            expect(described_class.get_applicable_scopables(Report)).to match_array([ScopableByCity, ScopableByClearance])
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
              clearance = create(:clearance, name: 'secret', level: 1)
              in_report = create(:report, city: @in_city, clearance: clearance)
              out_report = create(:report, city: out_city, clearance: clearance)
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

      end
    end
  end
end

