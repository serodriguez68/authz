describe Authz do

  describe '.force_authentication_method=' do
    it 'should allow the modification of the force_authentication_method configuration variable' do
      prev = described_class.force_authentication_method
      described_class.force_authentication_method = :foo
      expect(described_class.force_authentication_method).to eq :foo
      described_class.force_authentication_method = prev
    end
  end

  describe '.current_user_method=' do
    it 'should allow the modification of the current_user_method configuration variable' do
      prev = described_class.current_user_method
      described_class.current_user_method = :foo
      expect(described_class.current_user_method).to eq :foo
      described_class.current_user_method = prev
    end
  end

end