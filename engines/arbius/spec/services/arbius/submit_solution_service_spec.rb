# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::SubmitSolutionService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract) }

  it 'calls EngineContract#submit_solution with correct arguments and context' do
    from = '0xabc'
    taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    cid = '0xdeadbeef'
    ethereum_event_id = '1234'
    expected_context = { class: 'Arbius::SubmitSolutionService', task_id: taskid, from: from }
    expect(mock_engine_contract).to receive(:submit_solution).with(from: from, taskid: taskid, cid: cid, context: expected_context).and_return(ethereum_event_id)
    expect(service.call(from: from, taskid: taskid, cid: cid)).to eq(ethereum_event_id)
  end
end
