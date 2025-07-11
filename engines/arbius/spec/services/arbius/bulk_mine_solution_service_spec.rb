# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkMineSolutionService do
  let(:mock_generate_commitment_service) { double(:generate_commitment_service) }
  let(:mock_bulk_signal_commitments_service) { double(:bulk_signal_commitments_service) }
  let(:mock_bulk_submit_solutions_service) { double(:bulk_submit_solutions_service) }
  let(:mock_wait_for_transaction_service) { double(:wait_for_transaction_service) }
  let(:service) do
    described_class.new(
      generate_commitment_service: mock_generate_commitment_service,
      bulk_signal_commitments_service: mock_bulk_signal_commitments_service,
      bulk_submit_solutions_service: mock_bulk_submit_solutions_service,
      wait_for_transaction_service: mock_wait_for_transaction_service
    )
  end

  it 'mines solutions by generating commitments, signaling, submitting, and waiting for transactions' do
    from = '0xabc'
    taskids = [
      '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    ]
    cids = [ '0xdeadbeef', '0xbeefdead' ]
    commitments = [ 'commitment1', 'commitment2' ]
    tx_id_signal = 'txid_signal'
    tx_id_submit = 'txid_submit'

    # Expect generate_commitment to be called for each cid
    cids.each_with_index do |cid, i|
      expect(mock_generate_commitment_service).to receive(:generate_commitment)
        .with(sender: from, taskid: anything, cid: cid)
        .and_return(commitments[i])
    end

    expect(mock_bulk_signal_commitments_service).to receive(:call)
      .with(from: from, commitments: commitments)
      .and_return(tx_id_signal)
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: tx_id_signal)

    expect(mock_bulk_submit_solutions_service).to receive(:call)
      .with(from: from, taskids: taskids, cids: cids)
      .and_return(tx_id_submit)
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: tx_id_submit)

    service.call(from: from, taskids: taskids, cids: cids)
  end

  it 'raises LengthMismatchError if taskids and cids are not the same length' do
    from = '0xabc'
    taskids = [ '0x123', '0x456' ]
    cids = [ '0xdeadbeef' ]
    expect {
      service.call(from: from, taskids: taskids, cids: cids)
    }.to raise_error(described_class::LengthMismatchError, 'taskids and cids must have the same length')
  end
end
