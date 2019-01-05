module Authz
  module Controllers
    describe AuthorizationManager do
      let(:current_user) { build(:user) }
      let(:controller) { TestsController.new(current_user, 'an_action') }

      describe '#authorized?' do
        before(:each) do
          @role1 = create :authz_role
          @role2 = create :authz_role
          current_user.roles << [@role1, @role2]
          @report = create :report
        end
        it 'should raise an error when no scoping instance is provided' do
          expect {
            controller.authorized? controller: 'foo', action: 'bar'
          }.to raise_error described_class::MissingScopingInstance
        end

        it 'should not raise the MissingScopingInstance error when the skip_scoping option is used' do
          allow(PermissionManager).to receive(:has_permission?).and_return(true)
          expect {
            controller.authorized?(controller: 'foo', action: 'bar',
                                   skip_scoping: true)
          }.not_to raise_error
        end

        context 'when the user is authorized' do
          it 'should return true' do
            allow(PermissionManager).to receive(:has_permission?).and_return(true)
            allow(ScopingManager).to receive(:has_access_to_instance?).and_return(true)
            expect(
              controller.authorized?(controller: 'foo', action: 'bar', using: 'baz')
            ).to eq true
          end
        end
        
        context 'when the user is not authorized' do
          it 'should exhaust all roles and then return false' do
            con = 'controller'
            act = 'action'
            
            expect(PermissionManager).to(
              receive(:has_permission?).with(@role1, con, act)
                .once
                .and_return(true)
            )
            
            expect(PermissionManager).to(
              receive(:has_permission?).with(@role2, con, act)
                .once.and_return(true)
            )
            
            expect(ScopingManager).to(
              receive(:has_access_to_instance?).with(@role1,
                                                     @report,
                                                     current_user)
                .once
                .and_return(false)
            )

            expect(ScopingManager).to(
              receive(:has_access_to_instance?).with(@role2,
                                                     @report,
                                                     current_user)
                .once
                .and_return(false)
            )
            
            expect(
              controller.authorized?(controller: con, action: act, using: @report)
            ).to be false
          end

          it 'should skip checking for scoping privileges when the role has no permission' do
            con = 'controller'
            act = 'action'

            expect(PermissionManager).to(
              receive(:has_permission?).with(@role1, con, act)
                .once
                .and_return(false)
            )

            expect(PermissionManager).to(
              receive(:has_permission?).with(@role2, con, act)
                .once.and_return(false)
            )

            expect(ScopingManager).not_to(receive(:has_access_to_instance?))

            expect(ScopingManager).not_to(receive(:has_access_to_instance?))

            expect(
              controller.authorized?(controller: con, action: act, using: @report)
            ).to be false
          end
        end
      end
      
      describe '#authorize' do
        
        it 'should disable raising the authorization not performed error' do
          allow(controller).to receive(:authorized?).and_return true
          controller.authorize skip_scoping: true
          expect { controller.verify_authorized { nil } }.not_to raise_error
        end

        it 'should raise a NotAuthorized exception when not authorized' do
          allow(controller).to receive(:authorized?).and_return false
          expect {
            controller.authorize skip_scoping: true
          }.to raise_error described_class::NotAuthorized
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
          expect { controller.verify_authorized { nil } }.to(
            raise_error described_class::AuthorizationNotPerformedError
          )
        end
      end

      describe '#authorized_path?' do

        it 'should call the #authorized? method with the correct arguments' do
          # Setup a route that is resolved by the TestsController
          con = 'tests'
          act = 'new'
          using = Object.new
          skip_scoping = false
          result = true

          Rails.application.routes.draw do
            get 'test/new', controller: 'tests', action: 'new'
          end

          expect(controller).to(
            receive(:authorized?).with(controller: 'tests',
                                       action: 'new',
                                       using: using,
                                       skip_scoping: skip_scoping)
              .and_return(result)
          )

          expect(
            controller.authorized_path?('test/new', method: :get,
                                        using: using,
                                        skip_scoping: skip_scoping)
          ).to eq result

          Rails.application.reload_routes!
        end
      end

    end
  end
end


