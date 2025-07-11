# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::MineSolutionService do
  let(:mock_generate_commitment_service) { double(:generate_commitment_service) }
  let(:mock_signal_commitment_service) { double(:signal_commitment_service) }
  let(:mock_submit_solution_service) { double(:submit_solution_service) }
  let(:mock_wait_for_transaction_service) { double(:wait_for_transaction_service) }
  let(:service) do
    described_class.new(
      generate_commitment_service: mock_generate_commitment_service,
      signal_commitment_service: mock_signal_commitment_service,
      submit_solution_service: mock_submit_solution_service,
      wait_for_transaction_service: mock_wait_for_transaction_service
    )
  end

  it 'calls the services in order with correct arguments and waits for transactions' do
    from = '0xabc'
    taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    cid = '0xdeadbeef'
    commitment = '0xcommitmenthash'
    tx_id1 = '0xsignalcommitmenttx'
    tx_id2 = '0xsubmitsolutiontx'

    expect(mock_generate_commitment_service).to receive(:generate_commitment_onchain).with(sender: from, taskid: taskid, cid: cid).and_return(commitment).ordered
    expect(mock_signal_commitment_service).to receive(:call).with(from: from, commitment: commitment).and_return(tx_id1).ordered
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: tx_id1).ordered
    expect(mock_submit_solution_service).to receive(:call).with(from: from, taskid: taskid, cid: cid).and_return(tx_id2).ordered
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: tx_id2).ordered

    service.call(from: from, taskid: taskid, cid: cid)
  end
end
