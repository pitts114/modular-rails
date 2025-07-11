# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkSignalCommitmentsService do
  let(:mock_bulk_tasks_contract) { double(:bulk_tasks_contract) }
  let(:service) { described_class.new(bulk_tasks_contract: mock_bulk_tasks_contract) }

  it 'calls BulkTasksContract#bulk_signal_commitment with correct arguments and context' do
    from = '0xabc'
    commitments = [
      '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    ]
    result = 'ok'
    expected_context = { class: 'Arbius::BulkSignalCommitmentsService', from: from }
    expect(mock_bulk_tasks_contract).to receive(:bulk_signal_commitment).with(from: from, commitments: commitments, context: expected_context).and_return(result)
    expect(service.call(from: from, commitments: commitments)).to eq(result)
  end
end
