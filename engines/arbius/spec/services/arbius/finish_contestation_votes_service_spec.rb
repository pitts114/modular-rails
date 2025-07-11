require 'rails_helper'

RSpec.describe Arbius::FinishContestationVotesService do
  let(:engine_contract) { double(:engine_contract, min_contestation_vote_period_time: 100, contestation_vote_extension_time: 10) }
  let(:finish_contestation_vote_service) { double(:finish_contestation_vote_service) }
  let(:repository) { double(:solution_submitted_event_repository) }
  let(:contestation_vote_repository) { double(:contestation_vote_repository) }
  let(:validator_model) { double(:validator) }
  let(:time) { class_double(Time, now: Time.now) }
  let(:service) do
    described_class.new(
      engine_contract: engine_contract,
      finish_contestation_vote_service: finish_contestation_vote_service,
      repository: repository,
      contestation_vote_repository: contestation_vote_repository,
      validator_model: validator_model,
      time: time
    )
  end

  let(:solution_event) { double(:solution_submitted_event, created_at: time.now - 200, task: 'task-1') }
  let(:validator_addresses) { %w[0xabc 0xdef] }

  before do
    allow(validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
  end

  it 'calls finish_contestation_vote_service for each eligible solution' do
    buffer = described_class::BUFFER_SECONDS
    min_period = engine_contract.min_contestation_vote_period_time.to_i
    extension_time = engine_contract.contestation_vote_extension_time.to_i
    expected_older_than = time.now - (min_period + buffer)
    allow(repository).to receive(:old_contested_solutions).with(older_than: expected_older_than, per_vote_extension_time: extension_time).and_return([ solution_event ])
    allow(repository).to receive(:attacked_solutions_with_yea_majority).with(older_than: expected_older_than, per_vote_extension_time: extension_time).and_return([])
    allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: solution_event.task).and_return([ :vote1, :vote2 ])
    from_address = validator_addresses.first
    allow(validator_addresses).to receive(:sample).and_return(from_address)
    expect(finish_contestation_vote_service).to receive(:call).with(
      from: from_address,
      solution_submitted_event: solution_event,
      vote_count: 2
    )
    service.call
  end

  it 'calls finish_contestation_vote_service for each eligible solution from both old_contested_solutions and attacked_solutions_with_yea_majority' do
    buffer = described_class::BUFFER_SECONDS
    min_period = engine_contract.min_contestation_vote_period_time.to_i
    extension_time = engine_contract.contestation_vote_extension_time.to_i
    expected_older_than = time.now - (min_period + buffer)
    solution_event1 = double(:solution_submitted_event, created_at: time.now - 200, task: 'task-1')
    solution_event2 = double(:solution_submitted_event, created_at: time.now - 300, task: 'task-2')
    allow(repository).to receive(:old_contested_solutions).with(older_than: expected_older_than, per_vote_extension_time: extension_time).and_return([ solution_event1 ])
    allow(repository).to receive(:attacked_solutions_with_yea_majority).with(older_than: expected_older_than, per_vote_extension_time: extension_time).and_return([ solution_event2 ])
    allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: solution_event1.task).and_return([ :vote1, :vote2 ])
    allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: solution_event2.task).and_return([ :vote1 ])
    from_address = validator_addresses.first
    allow(validator_addresses).to receive(:sample).and_return(from_address)
    expect(finish_contestation_vote_service).to receive(:call).with(
      from: from_address,
      solution_submitted_event: solution_event1,
      vote_count: 2
    )
    expect(finish_contestation_vote_service).to receive(:call).with(
      from: from_address,
      solution_submitted_event: solution_event2,
      vote_count: 1
    )
    service.call
  end

  it 'does nothing if no eligible solutions' do
    allow(repository).to receive(:old_contested_solutions).and_return([])
    allow(repository).to receive(:attacked_solutions_with_yea_majority).and_return([])
    expect(finish_contestation_vote_service).not_to receive(:call)
    service.call
  end

  it 'does nothing if no eligible solutions from either query' do
    allow(repository).to receive(:old_contested_solutions).and_return([])
    allow(repository).to receive(:attacked_solutions_with_yea_majority).and_return([])
    expect(finish_contestation_vote_service).not_to receive(:call)
    service.call
  end
end
