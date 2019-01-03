module Authz
  module Controllers
    describe AuthorizationManager do
      let(:current_user) { build(:user) }
      let(:controller) { TestsController.new(current_user, 'an_action') }
      before(:each) do
        allow(PermissionManager).to receive(:check_permission!).and_return(nil)
      end

      describe '#authorize' do
        it 'should raise an error when no scoping instance is provided' do
          expect { controller.authorize }.to raise_error described_class::MissingScopingInstance
        end

        it 'should not raise the MissingScopingInstance error when the skip_scoping option is used' do
          expect { controller.authorize(skip_scoping: true) }.not_to raise_error
        end
        
        it 'should call PermissionManager.check_permission!' do
          expect(PermissionManager).to receive(:check_permission!).with(current_user,
                                                                        controller.params[:controller],
                                                                        controller.params[:action])
          controller.authorize skip_scoping: true
        end

        it 'should disable raising the authorization not performed error' do
          controller.authorize skip_scoping: true
          expect { controller.verify_authorized { nil } }.not_to raise_error
        end
      end

      describe '#skip_authorization' do
        it 'should disable raising the authorization not performed error' do
          controller.skip_authorization
          expect { controller.verify_authorized { nil } }.not_to raise_error
        end
      end

      describe '#verify_authorized' do
        it 'should raise an error when authorization has not been performed ' do
          expect { controller.verify_authorized { nil } }.to raise_error described_class::AuthorizationNotPerformedError
        end
      end

    end
  end
end


