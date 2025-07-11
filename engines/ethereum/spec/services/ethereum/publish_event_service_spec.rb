require 'rails_helper'

RSpec.describe Ethereum::PublishEventService do
  let(:notifications) { double(:notifications) }
  let(:event_decoder_service) { double(:event_decoder_service) }
  let(:ethereum_event_model) { double(:ethereum_event_model) }
  let(:service) { described_class.new(notifications:, event_decoder_service:, ethereum_event_model:) }

  let(:ethereum_event) do
    double(
      :ethereum_event,
      chain_id: 1,
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      some: :attr,
      id: '123',
      block_hash: '0xblock',
      block_number: 42,
      transaction_hash: '0xtrx',
      transaction_index: 7
    )
  end

  let(:decoded_event) do
    {
      event_name: 'TaskSubmitted',
      event_data: { foo: 'bar', baz: 123 }
    }
  end

  describe '#call' do
    it 'decodes the event and instruments a notification' do
      allow(ethereum_event_model).to receive(:find).with('123').and_return(ethereum_event)
      expect(event_decoder_service).to receive(:call).with(ethereum_event: ethereum_event).and_return(decoded_event)
      expect(ethereum_event).to receive(:chain_id).and_return(1)
      expect(ethereum_event).to receive(:address).and_return('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045')
      expect(notifications).to receive(:instrument).with(
        'ethereum.1_0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045_task_submitted',
        {
          foo: 'bar',
          baz: 123,
          ethereum_event_id: '123',
          block_hash: '0xblock',
          block_number: 42,
          chain_id: 1,
          contract_address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
          transaction_hash: '0xtrx',
          transaction_index: 7
        }
      )

      service.call(ethereum_event_id: '123')
    end

    it 'raises UnknownEventError if decoding fails with UnknownEventError' do
      allow(ethereum_event_model).to receive(:find).with('123').and_return(ethereum_event)
      allow(event_decoder_service).to receive(:call).with(ethereum_event: ethereum_event).and_raise(Ethereum::EventDecoderService::UnknownEventError.new('bad event'))
      expect {
        service.call(ethereum_event_id: '123')
      }.to raise_error(Ethereum::PublishEventService::UnknownEventError, /Failed to decode event/)
    end

    it 'raises EventNotFoundError if the event is not found' do
      allow(ethereum_event_model).to receive(:find).with('123').and_raise(ActiveRecord::RecordNotFound)
      expect {
        service.call(ethereum_event_id: '123')
      }.to raise_error(Ethereum::PublishEventService::EventNotFoundError, /Ethereum event with ID 123 not found/)
    end
  end
end
