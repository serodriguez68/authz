describe Authz do

  describe '.scopables_directory' do

    it 'should be configurable through the writer method' do
      default_directory = described_class.scopables_directory
      custom_directory = '/my/custom/directory'
      expect(described_class.scopables_directory).not_to eq custom_directory
      described_class.scopables_directory = custom_directory
      expect(described_class.scopables_directory).to eq custom_directory
      # Change directory back to normal (teardown of test setup)
      described_class.scopables_directory = default_directory
    end
  end
end