module Authz
  describe Cache do
    
    let(:cache_configurator) { Authz }

    describe '.fetch' do
      describe 'when cross_request_caching= true' do
        before(:each) do
          cache_configurator.cross_request_caching = true
        end

        let(:name) { [(1..100).to_a.sample, Time.now.to_i] }
        let(:options) { { expires_in: 20.minutes } }
        let(:operation) { Proc.new { 5+5 } }

        it 'should call Rails cache passing down all arguments and block' do
          expect(Rails.cache).to(
            receive(:fetch).with(name, options).and_call_original { |&block| expect(block).to be(operation) }
          )
          expect(described_class.fetch(name, options, &operation)).to eq 10
        end

        it 'should not call the block when a cache is formed' do
          operation = Proc.new { 1+1 }
          described_class.fetch(name, options, &operation)
          expect(operation).not_to receive(:call)
          described_class.fetch(name, options, &operation)
        end
      end

      describe 'when cross_request_caching= false'  do
        before(:each) do
          cache_configurator.cross_request_caching = false
        end

        it 'should directly call the block without calling Rails.cache' do
          name = 'foo'
          options = { expires_in: 20.minutes }
          expect(Rails.cache).not_to(receive(:fetch))
          expect(
            described_class.fetch(name, options) { 5+12 }
          ).to eq 17
        end
      end
    end


    
  end
end