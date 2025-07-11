require 'rails_helper'

RSpec.describe Arbius::ContestationVoteFinishEventRepository do
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
      start_idx: 1,
      end_idx: 2
    }
  end

  describe '.save!' do
    it 'creates both an EthereumEventDetail and a ContestationVoteFinishEvent' do
      expect {
        described_class.save!(attributes: attributes)
      }.to change(Arbius::EthereumEventDetail, :count).by(1)
       .and change(Arbius::ContestationVoteFinishEvent, :count).by(1)
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
