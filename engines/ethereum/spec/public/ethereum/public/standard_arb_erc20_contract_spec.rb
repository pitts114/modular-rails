# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Public::StandardArbErc20Contract do
  let(:contract_address) { '0x123' }
  let(:client) { double(:client, chain_id: 1) }
  let(:contract) { double(:contract) }
  let(:send_transaction_job) { double(:send_transaction_job) }
  let(:ethereum_transaction_model) { double(:ethereum_transaction_model) }
  let(:abi) { [ { 'name' => 'transfer', 'inputs' => [ { 'type' => 'address' }, { 'type' => 'uint256' } ] } ] }

  before do
    allow(described_class).to receive(:load_abi).and_return(abi)
  end

  subject(:service) do
    described_class.new(
      contract_address: contract_address,
      client: client,
      contract: contract,
      send_transaction_job: send_transaction_job,
      ethereum_transaction_model: ethereum_transaction_model
    )
  end

  describe '#balance_of' do
    it 'calls the contract balanceOf method' do
      expect(client).to receive(:call).with(contract, 'balanceOf', '0xabc').and_return(100)
      expect(service.balance_of(account: '0xabc')).to eq(100)
    end
  end

  describe '#allowance' do
    it 'calls the contract allowance method' do
      expect(client).to receive(:call).with(contract, 'allowance', '0xabc', '0xdef').and_return(50)
      expect(service.allowance(owner: '0xabc', spender: '0xdef')).to eq(50)
    end
  end

  describe '#approve' do
    it 'encodes and enqueues an approve transaction' do
      function_abi = double(:function_abi)
      data = '0xdeadbeef'
      allow(service).to receive(:find_function_abi!).with('approve', [ 'address', 'uint256' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xdef', 42 ]).and_return(data)
      expect(service).to receive(:enqueue_transaction).with(from: '0xabc', data: data)
      service.approve(from: '0xabc', spender: '0xdef', amount: 42)
    end
  end

  describe '#transfer' do
    it 'encodes and enqueues a transfer transaction' do
      function_abi = double(:function_abi)
      data = '0xfeedface'
      allow(service).to receive(:find_function_abi!).with('transfer', [ 'address', 'uint256' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xdef', 99 ]).and_return(data)
      expect(service).to receive(:enqueue_transaction).with(from: '0xabc', data: data)
      service.transfer(from: '0xabc', recipient: '0xdef', amount: 99)
    end
  end

  describe 'private #enqueue_transaction' do
    it 'creates a pending transaction and enqueues the job, returning the new record id' do
      data = '0xdata'
      transaction = double(id: 789)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xabc',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xabc', 1)
      result = service.send(:enqueue_transaction, from: '0xabc', data: data)
      expect(result).to eq(789)
    end
  end
end
