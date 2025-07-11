require 'rails_helper'

RSpec.describe Arbius::MarkSolutionForAttackJob, type: :job do
  let(:service) { double(:mark_solution_for_attack_service) }

  before do
    stub_const('Arbius::MarkSolutionForAttackService', Class.new)
    allow(Arbius::MarkSolutionForAttackService).to receive(:new).and_return(service)
  end

  it 'calls the MarkSolutionForAttackService with the correct task_id' do
    expect(service).to receive(:call).with(task_id: 'task-123')
    described_class.new.perform('task-123')
  end
end
