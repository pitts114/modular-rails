require 'rails_helper'

RSpec.describe Arbius::SolutionSubmittedService do
  let(:payload) do
    {
      ethereum_event_id: 'event-1',
      block_hash: '0xabc',
      block_number: 1,
      chain_id: 1,
      contract_address: '0xdef',
      transaction_hash: '0x123',
      transaction_index: 0,
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      task: 'task-1'
    }
  end

  let(:repository) { double(:repository) }
  let(:service) { described_class.new(repository: repository) }

  it 'calls the repository to save the event' do
    expect(repository).to receive(:save!).with(attributes: payload)
    service.call(payload: payload)
  end

  it 'rescues RecordNotUnique and does not raise' do
    allow(repository).to receive(:save!).and_raise(Arbius::SolutionSubmittedEventRepository::RecordNotUnique)
    expect {
      service.call(payload: payload)
    }.not_to raise_error
  end
end
