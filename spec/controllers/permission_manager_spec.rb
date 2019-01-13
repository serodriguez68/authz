module Authz
  module Controllers
    describe PermissionManager do
      let(:current_user) { build :user }

      describe '.has_permission?' do

        let!(:r) {create :authz_role}
        let!(:bp) {create :authz_business_process}
        let!(:ca) {create :authz_controller_action}
        let!(:bphca) {create :authz_business_process_has_controller_action,
                             controller_action: ca, business_process: bp}
        let!(:rhpb) {create :authz_role_has_business_process,
                            business_process: bp, role: r}

        it 'should return true for an assigned controller action' do
          clearance = described_class.has_permission?(r, ca.controller, ca.action)
          expect(clearance).to be true
        end

        it 'should  return false for an unassigned controller action' do
          clearance = described_class.has_permission?(r, ca.controller, 'foo')
          expect(clearance).to be false
        end
      end

    end
  end
end