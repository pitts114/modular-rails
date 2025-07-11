# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkClaimUncontestedSolutionsService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:mock_bulk_claim_solution_service) { double(:bulk_claim_solution_service) }
  let(:mock_repository) { double(:repository) }
  let(:mock_validator_model) { double(:validator_model) }
  let(:mock_time) { double(:time) }
  let(:service) do
    described_class.new(
      engine_contract: mock_engine_contract,
      bulk_claim_solution_service: mock_bulk_claim_solution_service,
      repository: mock_repository,
      validator_model: mock_validator_model,
      time: mock_time
    )
  end

  before do
    allow(ENV).to receive(:fetch).with('BULK_CLAIM_SOLUTIONS_LIMIT', '200').and_return('200')
  end

  it 'claims old uncontested solutions from a random validator address' do
    min_time = 1000
    now = 2000
    older_than = now - min_time
    solution_submitted_events = [ double(task: '0xtask1'), double(task: '0xtask2') ]
    validator_addresses = [ '0xval1', '0xval2' ]
    from_address = '0xval2'
    task_ids = [ '0xtask1', '0xtask2' ]
    context = { class: 'Arbius::BulkClaimUncontestedSolutionsService', task_ids: task_ids, from: from_address }
    expect(mock_engine_contract).to receive(:min_claim_solution_time).and_return(min_time)
    expect(mock_time).to receive(:now).and_return(now)
    expect(mock_repository).to receive(:old_uncontested_solutions).with(older_than: older_than, limit: 200).and_return(solution_submitted_events)
    expect(mock_validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
    allow(validator_addresses).to receive(:sample).and_return(from_address)
    expect(mock_bulk_claim_solution_service).to receive(:call).with(from: from_address, taskids: task_ids, context: context)
    service.call
  end

  it 'uses environment variable for limit' do
    min_time = 1000
    now = 2000
    older_than = now - min_time
    solution_submitted_events = [ double(task: '0xtask1') ]
    validator_addresses = [ '0xval1' ]
    from_address = '0xval1'
    task_ids = [ '0xtask1' ]
    context = { class: 'Arbius::BulkClaimUncontestedSolutionsService', task_ids: task_ids, from: from_address }

    allow(ENV).to receive(:fetch).with('BULK_CLAIM_SOLUTIONS_LIMIT', '200').and_return('50')
    expect(mock_engine_contract).to receive(:min_claim_solution_time).and_return(min_time)
    expect(mock_time).to receive(:now).and_return(now)
    expect(mock_repository).to receive(:old_uncontested_solutions).with(older_than: older_than, limit: 50).and_return(solution_submitted_events)
    expect(mock_validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
    allow(validator_addresses).to receive(:sample).and_return(from_address)
    expect(mock_bulk_claim_solution_service).to receive(:call).with(from: from_address, taskids: task_ids, context: context)
    service.call
  end

  it 'uses default limit when environment variable is not set' do
    min_time = 1000
    now = 2000
    older_than = now - min_time
    solution_submitted_events = [ double(task: '0xtask1') ]
    validator_addresses = [ '0xval1' ]
    from_address = '0xval1'
    task_ids = [ '0xtask1' ]
    context = { class: 'Arbius::BulkClaimUncontestedSolutionsService', task_ids: task_ids, from: from_address }

    # Don't mock ENV - let it use the real implementation with default
    expect(mock_engine_contract).to receive(:min_claim_solution_time).and_return(min_time)
    expect(mock_time).to receive(:now).and_return(now)
    expect(mock_repository).to receive(:old_uncontested_solutions).with(older_than: older_than, limit: 200).and_return(solution_submitted_events)
    expect(mock_validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
    allow(validator_addresses).to receive(:sample).and_return(from_address)
    expect(mock_bulk_claim_solution_service).to receive(:call).with(from: from_address, taskids: task_ids, context: context)
    service.call
  end

  it 'does nothing if there are no old uncontested solutions' do
    min_time = 1000
    now = 2000
    older_than = now - min_time
    solution_submitted_events = []
    validator_addresses = [ '0xval1', '0xval2' ]
    expect(mock_engine_contract).to receive(:min_claim_solution_time).and_return(min_time)
    expect(mock_time).to receive(:now).and_return(now)
    expect(mock_repository).to receive(:old_uncontested_solutions).with(older_than: older_than, limit: 200).and_return(solution_submitted_events)
    expect(mock_validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
    expect(mock_bulk_claim_solution_service).not_to receive(:call)
    service.call
  end
end
