# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::FeeEstimatorService do
  let(:eth_client) { double(:eth_client) }
  let(:service) { described_class.new(eth_client: eth_client) }

  describe '#recommended_fees' do
    it 'returns recommended max_fee_per_gas and max_priority_fee_per_gas' do
      block = {
        'result' => {
          'baseFeePerGas' => '0x3b9aca00' # 1_000_000_000 in hex (1 gwei)
        }
      }
      expect(eth_client).to receive(:eth_get_block_by_number).with('latest', false).and_return(block)
      expect(eth_client).to receive(:eth_max_priority_fee_per_gas).and_return({ 'result' => nil })
      fees = service.recommended_fees
      expect(fees[:max_priority_fee_per_gas]).to eq(1_000_000_000)
      expect(fees[:max_fee_per_gas]).to eq(1_000_000_000 * 2 + 1_000_000_000)
    end

    it 'returns recommended max_fee_per_gas and max_priority_fee_per_gas from eth_max_priority_fee_per_gas' do
      block = {
        'result' => {
          'baseFeePerGas' => '0x3b9aca00' # 1_000_000_000 in hex (1 gwei)
        }
      }
      priority_fee = 3_000_000_000
      expect(eth_client).to receive(:eth_get_block_by_number).with('latest', false).and_return(block)
      expect(eth_client).to receive(:eth_max_priority_fee_per_gas).and_return({ 'result' => '0xb2d05e00' }) # 3_000_000_000 in hex
      fees = service.recommended_fees
      expect(fees[:max_priority_fee_per_gas]).to eq(priority_fee)
      expect(fees[:max_fee_per_gas]).to eq(1_000_000_000 * 2 + priority_fee)
    end

    it 'falls back to alternative max priority fee if eth_max_priority_fee_per_gas is missing' do
      block = {
        'result' => {
          'baseFeePerGas' => '0x3b9aca00' # 1_000_000_000 in hex (1 gwei)
        }
      }
      expect(eth_client).to receive(:eth_get_block_by_number).with('latest', false).and_return(block)
      expect(eth_client).to receive(:eth_max_priority_fee_per_gas).and_return({ 'result' => nil })
      fees = service.recommended_fees(alternative_max_priority_fee_per_gas: 1_500_000_000)
      expect(fees[:max_priority_fee_per_gas]).to eq(1_500_000_000)
      expect(fees[:max_fee_per_gas]).to eq(1_000_000_000 * 2 + 1_500_000_000)
    end

    it 'falls back to alternative max priority fee if eth_max_priority_fee_per_gas raises' do
      block = {
        'result' => {
          'baseFeePerGas' => '0x3b9aca00' # 1_000_000_000 in hex (1 gwei)
        }
      }
      expect(eth_client).to receive(:eth_get_block_by_number).with('latest', false).and_return(block)
      expect(eth_client).to receive(:eth_max_priority_fee_per_gas).and_raise(StandardError)
      fees = service.recommended_fees(alternative_max_priority_fee_per_gas: 1_200_000_000)
      expect(fees[:max_priority_fee_per_gas]).to eq(1_200_000_000)
      expect(fees[:max_fee_per_gas]).to eq(1_000_000_000 * 2 + 1_200_000_000)
    end

    it 'raises an error if baseFeePerGas is missing' do
      block = { 'result' => {} }
      expect(eth_client).to receive(:eth_get_block_by_number).and_return(block)
      expect {
        service.recommended_fees
      }.to raise_error(Ethereum::FeeEstimatorService::Error, /Could not fetch baseFeePerGas/)
    end

    it 'raises an error if eth_client raises' do
      expect(eth_client).to receive(:eth_get_block_by_number).and_raise(StandardError, 'rpc failed')
      expect {
        service.recommended_fees
      }.to raise_error(Ethereum::FeeEstimatorService::Error, /rpc failed/)
    end
  end
end
