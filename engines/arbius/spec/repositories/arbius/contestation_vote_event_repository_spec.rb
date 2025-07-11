require 'rails_helper'

RSpec.describe Arbius::ContestationVoteEventRepository do
  let(:attributes) do
    {
      ethereum_event_id: SecureRandom.uuid,
      block_hash: '0xabc',
      block_number: 1,
      chain_id: 1,
      contract_address: '0xdef',
      transaction_hash: '0x123',
      transaction_index: 0,
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      task: 'task-1',
      yea: true
    }
  end

  describe '.save!' do
    it 'creates both an EthereumEventDetail and a ContestationVoteEvent' do
      expect {
        described_class.save!(attributes: attributes)
      }.to change(Arbius::EthereumEventDetail, :count).by(1)
       .and change(Arbius::ContestationVoteEvent, :count).by(1)
    end

    it 'raises RecordNotUnique if the ethereum_event_id is not unique' do
      described_class.save!(attributes: attributes)
      expect {
        described_class.save!(attributes: attributes)
      }.to raise_error(described_class::RecordNotUnique)
    end

    it 'raises RecordInvalid if required attributes are missing' do
      invalid_attrs = attributes.except(:address)
      expect {
        described_class.save!(attributes: invalid_attrs)
      }.to raise_error(described_class::RecordInvalid)
    end
  end
end
