# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Public::TransactionStatusService do
  let(:ethereum_transaction_model) { double(:ethereum_transaction_model) }
  let(:service) { described_class.new(ethereum_transaction_model: ethereum_transaction_model) }

  describe '#call' do
    let(:transaction_id) { 42 }
    let(:transaction) do
      double(
        from: '0xabc',
        to: '0xdef',
        value: 100,
        chain_id: 1,
        nonce: 5,
        data: '0xdata',
        tx_hash: '0xhash',
        raw_tx: '0xraw',
        signed_tx: '0xsigned',
        status: 'pending',
        broadcasted_at: Time.now,
        confirmed_at: nil,
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    it 'returns the transaction status hash if found' do
      expect(ethereum_transaction_model).to receive(:find_by).with(id: transaction_id).and_return(transaction)
      result = service.call(ethereum_transaction_id: transaction_id)
      expect(result).to include(
        from: '0xabc',
        to: '0xdef',
        value: 100,
        chain_id: 1,
        nonce: 5,
        data: '0xdata',
        tx_hash: '0xhash',
        raw_tx: '0xraw',
        signed_tx: '0xsigned',
        status: 'pending'
      )
    end

    it 'raises TransactionNotFoundError if not found' do
      expect(ethereum_transaction_model).to receive(:find_by).with(id: transaction_id).and_return(nil)
      expect {
        service.call(ethereum_transaction_id: transaction_id)
      }.to raise_error(described_class::TransactionNotFoundError, /Transaction with ID 42 not found/)
    end
  end
end
