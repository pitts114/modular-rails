require 'rails_helper'

RSpec.describe Arbius::ContestationVoteFinishService do
  let(:payload) do
    {
      ethereum_event_id: 'event-1',
      block_hash: '0xabc',
      block_number: 1,
      chain_id: 1,
      contract_address: '0xdef',
      transaction_hash: '0x123',
      transaction_index: 0,
      id: 'task-1',
      start_idx: 1,
      end_idx: 2
    }
  end

  let(:repository) { double(:repository) }
  let(:service) { described_class.new(repository: repository) }

  it 'calls the repository to save the event' do
    expected_attributes = payload.dup
    expected_attributes.delete(:id)
    expected_attributes[:task_id] = payload[:id]
    expect(repository).to receive(:save!).with(attributes: expected_attributes)
    service.call(payload: payload)
  end

  it 'rescues RecordNotUnique and does not raise' do
    allow(repository).to receive(:save!).and_raise(Arbius::ContestationVoteFinishEventRepository::RecordNotUnique)
    expect {
      service.call(payload: payload)
    }.not_to raise_error
  end
end
