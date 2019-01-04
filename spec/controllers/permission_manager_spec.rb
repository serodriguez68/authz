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

      describe '#authorized_path?' do
        let(:controller) { TestsController.new(current_user, 'new') }

        it 'should call user.clear_for? with the appropriate params given the path' do
          # Setup a route that is resolved by the TestsController
          Rails.application.routes.draw do
            get 'test/new', controller: 'tests', action: 'new'
          end
          expect(current_user).to receive(:clear_for?)
            .with(controller: 'tests', action: 'new')
          controller.authorized_path?('test/new', method: :get)
          Rails.application.reload_routes!
        end

      end
    end
  end
end