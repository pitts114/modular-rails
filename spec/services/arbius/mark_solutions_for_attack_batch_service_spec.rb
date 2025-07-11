require 'rails_helper'

RSpec.describe Arbius::MarkSolutionsForAttackBatchService do
  let(:repository) { double(:solution_submitted_event_repository) }
  let(:job) { double(:mark_solution_for_attack_job) }
  let(:service) do
    described_class.new(
      solution_submitted_event_repository: repository,
      mark_solution_for_attack_job: job
    )
  end

  let(:addresses) { [ '0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69', '0xC1E75C292c75A71E2F1449950C07203F0f09ADE7' ] }
  let(:count) { 2 }
  let(:event1) { double(:event, task: 'task1') }
  let(:event2) { double(:event, task: 'task2') }

  describe '#call' do
    it 'calls repository and enqueues the job for each solution' do
      expect(repository).to receive(:unattacked_for_addresses).with(
        addresses: addresses,
        limit: count,
        cutoff_time: kind_of(Time)
      ).and_return([ event1, event2 ])
      expect(job).to receive(:perform_later).with('task1')
      expect(job).to receive(:perform_later).with('task2')
      service.call(count: count, addresses: addresses)
    end

    it 'does nothing if repository returns empty' do
      expect(repository).to receive(:unattacked_for_addresses).and_return([])
      expect(job).not_to receive(:perform_later)
      service.call(count: count, addresses: addresses)
    end
  end
end
