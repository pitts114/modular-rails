# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::EthContractReadService do
  let(:eth_client) { double(:eth_client) }
  let(:service) { described_class.new(eth_client: eth_client) }
  let(:contract_address) { '0x1234567890abcdef1234567890abcdef12345678' }
  let(:data) { '0xabcdef' }
  let(:from) { '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd' }
  let(:eth_call_result) { { 'result' => '0x000000000000000000000000000000000000000000000000000000000000002a' } }

  it 'calls eth_call with correct params and returns the result' do
    expect(eth_client).to receive(:eth_call).with({ to: contract_address, data: data, from: from }).and_return(eth_call_result)
    result = service.call_contract(contract_address: contract_address, data: data, from: from)
    expect(result).to eq(eth_call_result['result'])
  end

  it 'calls eth_call without from if not provided' do
    expect(eth_client).to receive(:eth_call).with({ to: contract_address, data: data }).and_return(eth_call_result)
    result = service.call_contract(contract_address: contract_address, data: data)
    expect(result).to eq(eth_call_result['result'])
  end

  it 'raises an error if eth_call fails' do
    expect(eth_client).to receive(:eth_call).and_raise(StandardError, 'rpc failed')
    expect {
      service.call_contract(contract_address: contract_address, data: data)
    }.to raise_error(Ethereum::EthContractReadService::Error, /Failed to read from contract/)
  end
end
