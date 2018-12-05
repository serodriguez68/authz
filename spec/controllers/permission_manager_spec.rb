module Authz
  module Controllers
    describe PermissionManager do
      let(:current_user) { build :user }


      describe '.check_permission!' do
        it 'should call user#clear_for?' do
          expect(current_user).to receive(:clear_for?).with(controller: 'foo', action: 'bar')
                                                      .and_return(true)
          described_class.check_permission!(current_user, 'foo', 'bar')
        end

        it 'should rails an error when the permission is not granted' do
          allow(current_user).to receive(:clear_for?).and_return(false)
          expect { described_class.check_permission!(current_user, 'foo', 'bar') }
            .to raise_error described_class::PermissionNotGranted
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