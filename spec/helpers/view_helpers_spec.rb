module Authz
  module Helpers
    describe ViewHelpers do

      before(:each) do
        class (self.class)::TestsController < ApplicationController
          include Authz::Controllers::AuthorizationManager
          # Includes the helper
        end
        @cont_klass = (self.class)::TestsController
        @controller = @cont_klass.new
        @helper = @controller.helpers
      end

      describe '#authz_link_to' do
        let(:name) {'link name'}
        let(:path) { '/reports' }
        let(:method) { :post }
        let(:using) { :report }

        it 'should call the authorized_path? method with correct arguments' do
          expect(controller).to(
            receive(:authorized_path?)
              .with(path, method: method, using: using, skip_scoping: nil)
              .and_return(true)
          )
          helper.authz_link_to(name, path, { method: method }, using: using)
        end

        it 'should produce a link when authorized' do
          allow(controller).to receive(:authorized_path?).and_return true
          expect(
            helper.authz_link_to(name, path, { method: method }, using: using)
          ).to eq link_to(name, path, method: method)
        end

        it 'should return nil when not authorized' do
          allow(controller).to receive(:authorized_path?).and_return false
          expect(
            helper.authz_link_to(name, path, { method: method }, using: using)
          ).to be nil
        end
      end

    end
  end
end