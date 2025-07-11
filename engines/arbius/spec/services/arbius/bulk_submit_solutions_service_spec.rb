# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkSubmitSolutionsService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract) }

  it 'calls EngineContract#bulk_submit_solution with correct arguments and context' do
    from = '0xabc'
    taskids = [
      '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    ]
    cids = [ '0xdeadbeef', '0xbeefdead' ]
    ethereum_event_id = '5678'
    expected_context = { class: 'Arbius::BulkSubmitSolutionsService', task_ids: taskids, from: from }
    expect(mock_engine_contract).to receive(:bulk_submit_solution).with(from: from, taskids: taskids, cids: cids, context: expected_context).and_return(ethereum_event_id)
    expect(service.call(from: from, taskids: taskids, cids: cids)).to eq(ethereum_event_id)
  end
end
