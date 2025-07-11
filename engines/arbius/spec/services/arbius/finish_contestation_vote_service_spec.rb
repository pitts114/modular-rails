require 'rails_helper'

RSpec.describe Arbius::FinishContestationVoteService do
  let(:engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(engine_contract: engine_contract) }
  let(:solution_submitted_event) { double(:solution_submitted_event, task: '0xtaskid') }

  it 'calls finish_contestation_vote on the engine contract with correct arguments and context' do
    expected_context = { class: 'Arbius::FinishContestationVoteService', task_id: '0xtaskid', from: '0xfrom' }
    expect(engine_contract).to receive(:contestation_vote_finish).with(from: '0xfrom', taskid: '0xtaskid', amnt: 3, context: expected_context)
    service.call(from: '0xfrom', solution_submitted_event: solution_submitted_event, vote_count: 3)
  end
end
