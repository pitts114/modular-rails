# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::GasLimitService do
  describe '#call' do
    let(:eth_client) { double(:eth_client) }
    let(:service) { described_class.new(eth_client: eth_client) }
    let(:chain_id) { 1 }
    let(:from) { '0xfrom' }
    let(:to) { '0xto' }
    let(:data) { '0xdata' }
    let(:value) { 123 }

    it 'calls estimate_gas on the client with correct params and returns the result' do
      expect(eth_client).to receive(:eth_estimate_gas).with({ from: from, to: to, data: data, value: value }).and_return({ "result" => "0xa410" })
      result = service.call(chain_id: chain_id, from: from, to: to, data: data, value: value)
      expect(result).to eq(42_000)
    end

    it 'raises an error if estimate_gas fails' do
      allow(eth_client).to receive(:eth_estimate_gas).and_raise(StandardError, 'network error')
      expect {
        service.call(chain_id: chain_id, from: from, to: to, data: data, value: value)
      }.to raise_error(/Failed to estimate gas for contract call: network error/)
    end
  end

  describe '#for_eth_transfer' do
    let(:service) { described_class.new }

    it 'returns 21,000' do
      expect(service.for_eth_transfer(chain_id: 1)).to eq(21_000)
    end
  end

  describe '#for_contract_call' do
    let(:eth_client) { double(:eth_client) }
    let(:service) { described_class.new(eth_client: eth_client) }
    let(:chain_id) { 1 }
    let(:from) { '0xfrom' }
    let(:to) { '0xto' }
    let(:data) { '0xdata' }
    let(:value) { 123 }

    it 'calls estimate_gas on the client with correct params and returns the result' do
      expect(eth_client).to receive(:eth_estimate_gas).with({ from: from, to: to, data: data, value: value }).and_return({ "result" => "0xa410" })
      result = service.for_contract_call(chain_id: chain_id, from: from, to: to, data: data, value: value)
      expect(result).to eq(42_000)
    end

    it 'raises an error if estimate_gas fails' do
      allow(eth_client).to receive(:eth_estimate_gas).and_raise(StandardError, 'network error')
      expect {
        service.for_contract_call(chain_id: chain_id, from: from, to: to, data: data, value: value)
      }.to raise_error(/Failed to estimate gas for contract call: network error/)
    end
  end
end
