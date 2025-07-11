require 'rails_helper'

RSpec.describe Ethereum::EventDecoderService do
  let(:eth_event_utils) { double(:eth_event_utils) }
  let(:engine_contract) do
    double(:engine_contract,
      address: '0x123',
      abi: [ { 'name' => 'TaskSubmitted', 'type' => 'event' } ]
    )
  end
  let(:engine_task_submitted_decoder) { double(:engine_task_submitted_decoder) }
  let(:event_decoder_registry_entries) do
    [
      {
        address: engine_contract.address,
        event_name: 'TaskSubmitted',
        decoder: engine_task_submitted_decoder,
        contract: engine_contract
      }
    ]
  end
  let(:service) { described_class.new(eth_event_utils:, event_decoder_registry_entries:) }

  let(:ethereum_event) do
    double(:ethereum_event,
      address: engine_contract.address,
      data: '0xdeadbeef',
      id: 42,
      ethereum_event_topics: ethereum_event_topics
    )
  end

  let(:ethereum_event_topics) { double(:ethereum_event_topics) }
  let(:topics) { [ '0xtopic0', '0xtopic1' ] }
  let(:topic0) { topics.first }

  before do
    allow(eth_event_utils).to receive(:topic0_for).with(event_name: 'TaskSubmitted', abi: engine_contract.abi).and_return(topic0)
    allow(ethereum_event_topics).to receive(:order).with(topic_index: :asc).and_return(double(pluck: topics))
    allow(ethereum_event_topics).to receive(:find_by).with(topic_index: 0).and_return(double(topic: topic0))
  end

  describe '#call' do
    context 'when event is TaskSubmitted for engine contract' do
      it 'returns result with address, chain_id, and event_data' do
        allow(ethereum_event).to receive(:chain_id).and_return(1)
        allow(engine_task_submitted_decoder).to receive(:decode).with(data: '0xdeadbeef', topics: topics).and_return(
          id: '0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0',
          model: '0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a',
          fee: 1_000_000_000_000_000,
          sender: '0xb532a213B0d1fBC21D49EA44973E13351Bd1609e'
        )
        result = service.call(ethereum_event: ethereum_event)
        expect(result).to eq(
          address: '0x123',
          event_name: 'TaskSubmitted',
          chain_id: 1,
          event_data: {
            id: '0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0',
            model: '0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a',
            fee: 1_000_000_000_000_000,
            sender: '0xb532a213B0d1fBC21D49EA44973E13351Bd1609e'
          }
        )
      end
    end

    context 'when event is unknown' do
      before do
        allow(ethereum_event).to receive(:address).and_return('0xother')
      end
      it 'raises UnknownEventError' do
        expect {
          service.call(ethereum_event: ethereum_event)
        }.to raise_error(Ethereum::EventDecoderService::UnknownEventError)
      end
    end
  end
end
