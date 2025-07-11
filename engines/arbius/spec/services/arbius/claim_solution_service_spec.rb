# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::ClaimSolutionService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract) }
  let(:from) { '0xabc' }
  let(:taskid) { '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef' }

  it 'calls claim_solution on the engine contract with context' do
    expected_context = {
      class: 'Arbius::ClaimSolutionService',
      task_id: taskid,
      from: from
    }
    expect(mock_engine_contract).to receive(:claim_solution).with(from: from, taskid: taskid, context: expected_context)
    service.call(from: from, taskid: taskid)
  end

  it 'forwards a custom context if provided' do
    custom_context = { foo: 'bar', from: from, task_id: taskid }
    expect(mock_engine_contract).to receive(:claim_solution).with(from: from, taskid: taskid, context: custom_context)
    service.call(from: from, taskid: taskid, context: custom_context)
  end

  it 'uses the default context if context is nil' do
    expected_context = {
      class: 'Arbius::ClaimSolutionService',
      task_id: taskid,
      from: from
    }
    expect(mock_engine_contract).to receive(:claim_solution).with(from: from, taskid: taskid, context: expected_context)
    service.call(from: from, taskid: taskid, context: nil)
  end
end
