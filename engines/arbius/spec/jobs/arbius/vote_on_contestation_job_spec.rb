require 'rails_helper'

RSpec.describe Arbius::VoteOnContestationJob, type: :job do
  let(:service) { double(:service) }

  before do
    allow(Arbius::VoteOnContestationService).to receive(:new).and_return(service)
  end

  it 'calls VoteOnContestationService with the correct arguments' do
    expect(service).to receive(:call).with(task_id: 'task-123', from: '0xABC', yea: false)
    described_class.perform_now('task-123', '0xABC', false)
  end
end
