require 'rails_helper'

RSpec.describe Arbius::ContestationSubmittedService do
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
  let(:defend_solution_job) { double(:defend_solution_job) }
  let(:service) { described_class.new(repository:, defend_solution_job:) }

  it 'calls the repository and enqueues the defend solution job' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(double(task: payload[:task]))
    expect(defend_solution_job).to receive(:perform_later).with(payload[:task])
    service.call(payload: payload)
  end

  it 'rescues RecordNotUnique and does not raise' do
    allow(repository).to receive(:save!).and_raise(Arbius::ContestationSubmittedEventRepository::RecordNotUnique)
    expect(defend_solution_job).not_to receive(:perform_later)
    expect {
      service.call(payload: payload)
    }.not_to raise_error
  end
end
