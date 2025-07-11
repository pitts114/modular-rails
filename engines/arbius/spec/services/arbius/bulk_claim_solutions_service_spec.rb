# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkClaimSolutionsService do
  let(:mock_bulk_tasks_contract) { double(:bulk_tasks_contract) }
  let(:service) { described_class.new(bulk_tasks_contract: mock_bulk_tasks_contract) }

  it 'calls BulkTasksContract#claim_solutions with correct arguments and context' do
    from = '0xabc'
    taskids = [
      '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    ]
    tx_id = 'txid_claim'
    expected_context = {
      class: 'Arbius::BulkClaimSolutionsService',
      task_ids: taskids,
      from: from
    }
    expect(mock_bulk_tasks_contract).to receive(:claim_solutions).with(from: from, taskids: taskids, context: expected_context).and_return(tx_id)
    expect(service.call(from: from, taskids: taskids)).to eq(tx_id)
  end
end
