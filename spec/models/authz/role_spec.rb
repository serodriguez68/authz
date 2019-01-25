module Authz
  RSpec.describe Role, type: :model do
    describe 'validations' do
      it { is_expected.to validate_presence_of :code }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_uniqueness_of(:code) }
      it { is_expected.to validate_uniqueness_of(:name) }
      it { should allow_value('valid').for(:code) }
      it { should allow_value('valid_code').for(:code) }
      it { should_not allow_value('Invalid').for(:code) }
      it { should_not allow_value('9_a').for(:code) }

      it 'should automatically extract the code from the name' do
        bp = create(:authz_role, code: nil, name: 'City Director')
        expect(bp.code).to eq 'city_director'
      end
    end

    describe 'associations' do
      it { should have_many(:role_has_business_processes) }
      it { should have_many(:business_processes).through(:role_has_business_processes) }
      it { should have_many(:controller_actions).through(:business_processes) }
      it { should have_many(:role_grants) }
      it { should have_many(:users) }
      it { should have_many(:scoping_rules) }
    end

    describe '#has_permission?' do
      let!(:r) { create :authz_role }
      let!(:bp) { create :authz_business_process }
      let!(:ca) { create :authz_controller_action }
      let!(:bphca) { create :authz_business_process_has_controller_action,
                           controller_action: ca, business_process: bp }
      let!(:rhpb) { create :authz_role_has_business_process,
                          business_process: bp, role: r }

      it 'should return true for an assigned controller action' do
        clearance = r.has_permission?(ca.controller, ca.action)
        expect(clearance).to be true
      end

      it 'should  return false for an unassigned controller action' do
        clearance = r.has_permission?(ca.controller, 'foo')
        expect(clearance).to be false
      end
      
      describe 'caching' do
        before(:each) do
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should return from cache if nothing has changed' do
          expect(r).not_to receive(:has_permission?)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a controller action is updated' do
          ca.update(controller: ca.controller)
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a granted controller action is destroyed' do
          ca.destroy
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a controller action is added to a granted business process' do
          ca2 = create :authz_controller_action
          bp.controller_actions << ca2
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a controller action is directly removed from a granted business process' do
          bphca.destroy
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a bp_has_ca is updated' do
          ca2 = create :authz_controller_action
          bphca.update(controller_action: ca2)
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a controller action is removed from a granted business process using the controller association' do
          ca.update(business_process_ids: [])
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a controller action is removed from a granted business process using the business process association' do
          bp.update(controller_action_ids: [])
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache then a granted business process is destroyed' do
          bp.destroy
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when the role is assigned a new business process' do
          bp2 = create :authz_business_process
          r.business_processes << bp2
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when a role_has_bp is updated' do
          bp2 = create :authz_business_process
          rhpb.update(business_process: bp2)
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when the role is directly withdrawn from a business process' do
          rhpb.destroy
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when the role is withdrawn from a business process through the business process association' do
          bp.update(role_ids: [])
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

        it 'should refresh the cache when the role is withdrawn from a business process through the role association' do
          r.update(business_process_ids: [])
          r.reload
          expect(r).to receive(:has_permission?).with(ca.controller, ca.action)
          r.cached_has_permission?(ca.controller, ca.action)
        end

      end
    end


    describe '#granted_keyword_for' do
      let!(:r) { create :authz_role }
      let!(:scopable1) { ScopableByCity }
      let!(:keyword) { scopable1.available_keywords.first }
      let!(:sr1) { create :authz_scoping_rule, scopable: scopable1, role: r, keyword: keyword }
      let!(:scopable2) { ScopableByClearance }

      it 'should return the keyword granted for the given scopable' do
        expect(r.granted_keyword_for(scopable1)).to eq keyword
      end

      it 'should raise an exception if the role does not have a scoping rule for the given scopable' do
        expect{ r.granted_keyword_for(scopable2) }.to(
          raise_error(ActiveRecord::RecordNotFound)
        )
      end

      describe 'caching' do
        # Caches the result to test expiration
        before(:each) { r.cached_granted_keyword_for(scopable1) }

        it 'should return from cache if nothing has changed' do
          expect(r).not_to receive(:granted_keyword_for)
          r.cached_granted_keyword_for(scopable1)
        end

        it 'should refresh the cache when a scoping rule is edited' do
          sr1.update!(updated_at: Time.now)
          r.reload
          expect(r).to receive(:granted_keyword_for).with(scopable1)
          r.cached_granted_keyword_for(scopable1)
        end

        it 'should refresh the cache when another scoping rule is created' do
          create :authz_scoping_rule, scopable: scopable2.to_s, role: r
          r.reload
          expect(r).to receive(:granted_keyword_for).with(scopable1)
          r.cached_granted_keyword_for(scopable1)
        end

        it 'should refresh the cache when another scoping rule is destroyed' do
          sr2 = create :authz_scoping_rule, scopable: scopable2.to_s, role: r
          r.reload
          r.granted_keyword_for(scopable1) # regenerate cache after create
          sr2.destroy
          r.reload
          expect(r).to receive(:granted_keyword_for).with(scopable1)
          r.cached_granted_keyword_for(scopable1)
        end

      end

    end
  end
end
