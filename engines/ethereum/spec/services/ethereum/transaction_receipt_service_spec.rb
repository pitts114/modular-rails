# frozen_string_literal: true

require 'rails_helper'

# Define a dummy Eth module and Client class for mocking
module Eth
  class Client
    def eth_get_transaction_receipt(_tx_hash); end
  end
end

RSpec.describe Ethereum::TransactionReceiptService, type: :service do
  let(:eth_client) { double(:eth_client) }
  let(:service) { described_class.new(eth_client: eth_client) }
  let(:tx_hash) { '0x123abc' }

  describe '#fetch' do
    context 'when the transaction receipt is found' do
      let(:receipt) { { 'blockNumber' => '0x1b4', 'status' => '0x1' } }
      before do
        allow(eth_client).to receive(:eth_get_transaction_receipt).with(tx_hash).and_return({ 'result' => receipt })
      end

      it 'returns the transaction receipt' do
        expect(service.fetch(tx_hash:)).to eq(receipt)
      end
    end

    context 'when the transaction receipt is not found' do
      before do
        allow(eth_client).to receive(:eth_get_transaction_receipt).with(tx_hash).and_return({ 'result' => nil })
      end

      it 'returns nil' do
        expect(service.fetch(tx_hash:)).to be_nil
      end
    end

    context 'when an error occurs' do
      before do
        allow(eth_client).to receive(:eth_get_transaction_receipt).with(tx_hash).and_raise(StandardError.new('boom'))
      end

      it 'raises an error' do
        expect { service.fetch(tx_hash:) }.to raise_error(/Failed to fetch transaction receipt: boom/)
      end
    end
  end
end
