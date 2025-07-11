require 'rails_helper'

RSpec.describe Arbius::ClaimUncontestedSolutionsService, type: :service do
  let(:engine_contract) { double(:engine_contract) }
  let(:claim_solution_service) { double(:claim_solution_service) }
  let(:repository) { double(:repository) }
  let(:time) { double(:time) }
  let(:validator_model) { double(:validator_model) }
  let(:validator_addresses) { [ '0xValidator1', '0xValidator2' ] }
  let(:service) do
    described_class.new(
      engine_contract: engine_contract,
      claim_solution_service: claim_solution_service,
      repository: repository,
      validator_model: validator_model,
      time: time
    )
  end

  let(:min_time) { 3600 } # 1 hour
  let(:now) { Time.parse('2025-06-29 12:00:00 UTC') }
  let(:older_than) { now - min_time }
  let(:event1) { double(:solution_submitted_event, address: '0xMiner1', task: 'task1') }
  let(:event2) { double(:solution_submitted_event, address: '0xMiner2', task: 'task2') }

  before do
    allow(engine_contract).to receive(:min_claim_solution_time).and_return(min_time)
    allow(time).to receive(:now).and_return(now)
    allow(repository).to receive(:old_uncontested_solutions).with(older_than: older_than).and_return([ event1, event2 ])
    allow(validator_model).to receive(:pluck).with(:address).and_return(validator_addresses)
    allow(validator_addresses).to receive(:sample).and_return(validator_addresses.first, validator_addresses.last)
  end

  it 'claims all old uncontested solutions using random validator addresses and passes context' do
    expect(claim_solution_service).to receive(:call).with(
      from: '0xValidator1',
      taskid: 'task1',
      context: { class: 'Arbius::ClaimUncontestedSolutionsService', task_id: 'task1', from: '0xValidator1' }
    )
    expect(claim_solution_service).to receive(:call).with(
      from: '0xValidator2',
      taskid: 'task2',
      context: { class: 'Arbius::ClaimUncontestedSolutionsService', task_id: 'task2', from: '0xValidator2' }
    )
    service.call
  end
end
