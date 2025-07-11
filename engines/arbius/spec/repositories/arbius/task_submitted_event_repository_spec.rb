require 'rails_helper'

RSpec.describe Arbius::TaskSubmittedEventRepository do
  let(:attributes) do
    {
      ethereum_event_id: SecureRandom.uuid,
      block_hash: '0xabc',
      block_number: 1,
      chain_id: 1,
      contract_address: '0xdef',
      transaction_hash: '0x123',
      transaction_index: 0,
      task_id: 'task-1',
      model: 'modelA',
      fee: 100,
      sender: '0xabc'
    }
  end

  describe '.save!' do
    it 'creates both an EthereumEventDetail and a TaskSubmittedEvent' do
      expect {
        described_class.save!(attributes: attributes)
      }.to change(Arbius::EthereumEventDetail, :count).by(1)
       .and change(Arbius::TaskSubmittedEvent, :count).by(1)

      event = Arbius::TaskSubmittedEvent.last
      expect(event.task_id).to eq attributes[:task_id]
      expect(event.model).to eq attributes[:model]
      expect(event.fee).to eq attributes[:fee]
      expect(event.sender).to eq attributes[:sender]
      expect(event.arbius_ethereum_event_details_id).to eq Arbius::EthereumEventDetail.last.id
    end

    it 'raises RecordNotUnique if the ethereum_event_id is not unique' do
      described_class.save!(attributes: attributes)
      expect {
        described_class.save!(attributes: attributes)
      }.to raise_error(described_class::RecordNotUnique)
    end

    it 'raises RecordInvalid if required attributes are missing' do
      invalid_attrs = attributes.except(:task_id)
      expect {
        described_class.save!(attributes: invalid_attrs)
      }.to raise_error(described_class::RecordInvalid)
    end
  end
end
