module Authz
  describe YardMetadataService, type: :service do

    describe '#get_controller_action_description' do
      let(:metadata_service) { described_class.new }
      let(:controller_name) { 'folder/photos' }
      let(:action_name) { 'index' }
      let(:controller_filename) { "#{Rails.root}/app/controllers/#{controller_name}_controller.rb" }
      let(:action_symbol) { "Folder::PhotosController##{action_name}" }
      let(:description) { 'my super description' }
      let(:tag) { instance_double(YARD::Tags::Tag, text: description) }
      let(:code_object) { instance_double(YARD::CodeObjects::MethodObject, tag: tag) }

      it 'should return the @authz.description from the documentation' do
        expect(YARD).to receive(:parse).with(controller_filename)
        expect(YARD::Registry).to receive(:at).with(action_symbol).and_return code_object
        expect(
          metadata_service.get_controller_action_description(controller_name, action_name)
        ).to eq(description)
      end

      it 'should return nil when no @authz.description is present' do
        expect(YARD::Registry).to receive(:at).with(action_symbol).and_return nil
        expect(
          metadata_service.get_controller_action_description(controller_name, action_name)
        ).to be_nil
      end

      context 'when we call the ' do
        it 'should return the description from cache instead of parsing the file' do
          metadata_service.get_controller_action_description(controller_name, action_name)
          expect(YARD).not_to receive(:parse)
          metadata_service.get_controller_action_description(controller_name, action_name)
        end
      end


    end

  end
end