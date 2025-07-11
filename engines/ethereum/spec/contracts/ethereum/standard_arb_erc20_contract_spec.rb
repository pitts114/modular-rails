require 'rails_helper'

RSpec.describe Ethereum::StandardArbErc20Contract do
  let(:mock_client) { double(:client) }
  let(:mock_contract) { double(:contract) }
  let(:mock_eth_contract_call_service) { double(:eth_contract_call_service) }
  let(:mock_abi_encoder) { double(:abi_encoder) }
  let(:mock_eth_util) { double(:eth_util) }
  let(:contract_address) { '0x1234567890abcdef1234567890abcdef12345678' }

  subject do
    described_class.new(
      contract_address: contract_address,
      client: mock_client,
      contract: mock_contract,
      eth_contract_call_service: mock_eth_contract_call_service,
      abi_encoder: mock_abi_encoder,
      eth_util: mock_eth_util
    )
  end

  describe '#balance_of' do
    it 'calls the contract balanceOf function with the given account' do
      account = '0xabc'
      expect(mock_client).to receive(:call).with(mock_contract, 'balanceOf', account).and_return(12345)
      expect(subject.balance_of(account: account)).to eq(12345)
    end
  end

  describe '#allowance' do
    it 'calls the contract allowance function with the given owner and spender' do
      owner = '0xowner'
      spender = '0xspender'
      expect(mock_client).to receive(:call).with(mock_contract, 'allowance', owner, spender).and_return(999)
      expect(subject.allowance(owner: owner, spender: spender)).to eq(999)
    end
  end

  describe '#approve' do
    it 'encodes and calls the contract approve function with correct args' do
      from = '0xfrom'
      spender = '0xspender'
      amount = 1234
      function_abi = described_class::ABI.find { |f| f['name'] == 'approve' && f['type'] == 'function' }
      data = '0xdeadbeef'
      allow(mock_eth_contract_call_service).to receive(:call_contract).with(
        contract_address: contract_address,
        from: from,
        data: data
      ).and_return('tx_hash')
      allow(subject).to receive(:encode_function_call).with(function_abi, [ spender, amount ]).and_return(data)
      expect(subject.approve(from: from, spender: spender, amount: amount)).to eq('tx_hash')
    end
  end

  describe '#transfer' do
    it 'encodes and calls the contract transfer function with correct args' do
      from = '0xfrom'
      recipient = '0xrecipient'
      amount = 555
      function_abi = described_class::ABI.find { |f| f['name'] == 'transfer' && f['type'] == 'function' }
      data = '0xfeedbeef'
      allow(mock_eth_contract_call_service).to receive(:call_contract).with(
        contract_address: contract_address,
        from: from,
        data: data
      ).and_return('tx_hash')
      allow(subject).to receive(:encode_function_call).with(function_abi, [ recipient, amount ]).and_return(data)
      expect(subject.transfer(from: from, recipient: recipient, amount: amount)).to eq('tx_hash')
    end
  end
end
