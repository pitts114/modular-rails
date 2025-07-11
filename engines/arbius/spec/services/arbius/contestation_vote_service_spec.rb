require 'rails_helper'

RSpec.describe Arbius::ContestationVoteService do
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
      task: 'task-1',
      yea: true
    }
  end

  let(:repository) { double(:repository) }
  let(:validator_model) { double(:validator_model) }
  let(:miner_model) { double(:miner_model) }
  let(:defend_solution_job) { double(:defend_solution_job) }
  let(:attack_solution_model) { double(:attack_solution_model) }
  let(:attack_solution_job) { double(:attack_solution_job) }
  let(:solution_submitted_event_model) { double(:solution_submitted_event_model) }
  let(:service) do
    described_class.new(
      repository: repository,
      validator_model: validator_model,
      miner_model: miner_model,
      attack_solution_model: attack_solution_model,
      attack_solution_job: attack_solution_job,
      defend_solution_job: defend_solution_job,
      solution_submitted_event_model: solution_submitted_event_model
    )
  end

  let(:arbius_contestation_vote) { double(:arbius_contestation_vote, address: payload[:address], task: payload[:task]) }

  it 'calls the repository to save the event' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(validator_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(miner_model).to receive(:find_by).with(address: payload[:address]).and_return(double(:miner))
    allow(attack_solution_model).to receive(:find_by).with(task: payload[:task]).and_return(nil)
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(arbius_contestation_vote)
    expect(defend_solution_job).to receive(:perform_later).with(payload[:task])
    expect(attack_solution_job).not_to receive(:perform_later)
    service.call(payload: payload)
  end

  it 'enqueues the attack solution job when an attack solution exists for the task' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(validator_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(miner_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(attack_solution_model).to receive(:find_by).with(task: payload[:task]).and_return(double(:attack_solution))
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(arbius_contestation_vote)
    expect(defend_solution_job).not_to receive(:perform_later)
    expect(attack_solution_job).to receive(:perform_later).with(payload[:task])
    service.call(payload: payload)
  end

  it 'rescues RecordNotUnique and does not raise' do
    allow(repository).to receive(:save!).and_raise(Arbius::ContestationVoteEventRepository::RecordNotUnique)
    expect(defend_solution_job).not_to receive(:perform_later)
    expect(attack_solution_job).not_to receive(:perform_later)
    expect {
      service.call(payload: payload)
    }.not_to raise_error
  end

  it 'does not enqueue the defend_solution_job or attack_solution_job if the address on the contestation vote event is a validator' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(validator_model).to receive(:find_by).with(address: payload[:address]).and_return(double(:validator))
    allow(miner_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(attack_solution_model).to receive(:find_by).with(task: payload[:task]).and_return(nil)
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(arbius_contestation_vote)
    expect(defend_solution_job).not_to receive(:perform_later)
    expect(attack_solution_job).not_to receive(:perform_later)
    service.call(payload: payload)
  end

  it 'does not enqueue the defend_solution_job or attack_solution_job if the address on the contestation vote event is a miner' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(validator_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(miner_model).to receive(:find_by).with(address: payload[:address]).and_return(double(:miner))
    allow(attack_solution_model).to receive(:find_by).with(task: payload[:task]).and_return(nil)
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(arbius_contestation_vote)
    expect(defend_solution_job).to receive(:perform_later).with(payload[:task])
    expect(attack_solution_job).not_to receive(:perform_later)
    service.call(payload: payload)
  end

  it 'enqueues the defend_solution_job if the address on the contestation vote event is neither a validator nor a miner and not attack' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(validator_model).to receive(:find_by).with(address: payload[:address]).and_return(nil)
    allow(miner_model).to receive(:find_by).with(address: payload[:address]).and_return(double(:miner))
    allow(attack_solution_model).to receive(:find_by).with(task: payload[:task]).and_return(nil)
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(arbius_contestation_vote)
    expect(defend_solution_job).to receive(:perform_later).with(payload[:task])
    expect(attack_solution_job).not_to receive(:perform_later)
    service.call(payload: payload)
  end

  it 'raises SolutionSubmittedEventNotFoundError if no solution submitted event exists for the task' do
    expect(repository).to receive(:save!).with(attributes: payload).and_return(arbius_contestation_vote)
    allow(solution_submitted_event_model).to receive(:find_by).with(task: payload[:task]).and_return(nil)
    expect {
      service.call(payload: payload)
    }.to raise_error(Arbius::ContestationVoteService::SolutionSubmittedEventNotFoundError)
  end
end
