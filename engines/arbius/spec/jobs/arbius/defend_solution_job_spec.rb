require 'rails_helper'

RSpec.describe Arbius::DefendSolutionJob, type: :job do
  let(:service) { instance_double(Arbius::DefendSolutionService) }

  before do
    allow(Arbius::DefendSolutionService).to receive(:new).and_return(service)
  end

  it 'calls DefendSolutionService with the task_id' do
    expect(service).to receive(:call).with(task_id: 'task-123')
    described_class.perform_now('task-123')
  end
end
