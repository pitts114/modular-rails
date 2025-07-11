# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Public::BulkTasksContract do
  let(:client) { double(:client, chain_id: 1) }
  let(:contract_address) { '0xbulk' }
  let(:contract) { double(:contract) }
  let(:ethereum_transaction_model) { double(:ethereum_transaction_model) }
  let(:abi_encoder) { double(:abi_encoder) }
  let(:eth_util) { double(:eth_util) }
  let(:send_transaction_job) { double(:send_transaction_job) }
  let(:abi) { [ { 'name' => 'bulkSignalCommitment', 'inputs' => [ { 'type' => 'bytes32[]' } ] } ] }

  before do
    allow(described_class).to receive(:load_abi).and_return(abi)
    stub_const('ENV', ENV.to_hash)
  end

  subject(:service) do
    described_class.new(
      client: client,
      contract_address: contract_address,
      contract: contract,
      ethereum_transaction_model: ethereum_transaction_model,
      abi_encoder: abi_encoder,
      eth_util: eth_util,
      send_transaction_job: send_transaction_job
    )
  end

  describe '#bulk_signal_commitment' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xbulkdata'
      commitments = [ '0xabc', '0xdef' ]
      allow(service).to receive(:find_function_abi!).with('bulkSignalCommitment', [ 'bytes32[]' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ commitments ]).and_return(data)
      transaction = double(id: 42)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      result = service.bulk_signal_commitment(from: '0xfrom', commitments: commitments)
      expect(result).to eq(42)
    end
  end

  describe '#claim_solutions' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xclaimdata'
      taskids = [ '0xabc', '0xdef' ]
      allow(service).to receive(:find_function_abi!).with('claimSolutions', [ 'bytes32[]' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ taskids ]).and_return(data)
      transaction = double(id: 99)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      result = service.claim_solutions(from: '0xfrom', taskids: taskids)
      expect(result).to eq(99)
    end
  end
end
