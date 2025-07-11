require 'rails_helper'

RSpec.describe Ethereum::Public::LatestBlockNumberService do
  let(:mock_model) { class_double('Ethereum::EventPollerState') }
  let(:service_instance) { described_class.new(model: mock_model) }

  describe '#call' do
    it 'returns the last_processed_block for the event_poller poller' do
      poller_state = double('EventPollerState', last_processed_block: 42)
      expect(mock_model).to receive(:find_by).with(poller_name: 'event_poller').and_return(poller_state)
      expect(service_instance.call).to eq(42)
    end

    it 'returns 0 if no poller state is found' do
      expect(mock_model).to receive(:find_by).with(poller_name: 'event_poller').and_return(nil)
      expect(service_instance.call).to eq(0)
    end
  end
end
