# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::TransactionRepository, type: :model do
  let(:repository) { described_class.new }
  let(:from) { '0xSender' }
  let(:chain_id) { 5 }

  before do
    Ethereum::Transaction.delete_all
  end

  it 'yields the oldest locked pending transaction' do
    tx1 = Ethereum::Transaction.create!(from: from, to: '0x1', chain_id: chain_id, status: 'pending', value: 0, created_at: 1.hour.ago)
    Ethereum::Transaction.create!(from: from, to: '0x2', chain_id: chain_id, status: 'pending', value: 0, created_at: Time.now)
    yielded = nil
    repository.with_locked_pending_transaction(from: from, chain_id: chain_id) { |tx| yielded = tx }
    expect(yielded).to eq(tx1)
  end

  it 'yields nil if no transaction is found' do
    yielded = :not_called
    repository.with_locked_pending_transaction(from: from, chain_id: chain_id) { |tx| yielded = tx }
    expect(yielded).to be_nil
  end

  it 'does not yield non-pending transactions' do
    Ethereum::Transaction.create!(from: from, to: '0x1', chain_id: chain_id, status: 'confirmed', value: 0, created_at: Time.now)
    yielded = :not_called
    repository.with_locked_pending_transaction(from: from, chain_id: chain_id) { |tx| yielded = tx }
    expect(yielded).to be_nil
  end

  describe '#confirmed_transaction_with_highest_nonce' do
    it 'returns the confirmed transaction with the highest nonce for the given from and chain_id' do
      Ethereum::Transaction.create!(from: from, to: '0x1', chain_id: chain_id, status: 'confirmed', value: 0, nonce: 1)
      tx2 = Ethereum::Transaction.create!(from: from, to: '0x2', chain_id: chain_id, status: 'confirmed', value: 0, nonce: 2)
      Ethereum::Transaction.create!(from: from, to: '0x3', chain_id: chain_id, status: 'pending', value: 0, nonce: 3)
      result = repository.confirmed_transaction_with_highest_nonce(from: from, chain_id: chain_id)
      expect(result).to eq(tx2)
    end

    it 'returns nil if there are no confirmed transactions for the given from and chain_id' do
      Ethereum::Transaction.create!(from: from, to: '0x1', chain_id: chain_id, status: 'pending', value: 0, nonce: 1)
      result = repository.confirmed_transaction_with_highest_nonce(from: from, chain_id: chain_id)
      expect(result).to be_nil
    end

    it 'does not return confirmed transactions for other from or chain_id' do
      Ethereum::Transaction.create!(from: '0xOther', to: '0x1', chain_id: chain_id, status: 'confirmed', value: 0, nonce: 5)
      Ethereum::Transaction.create!(from: from, to: '0x1', chain_id: 99, status: 'confirmed', value: 0, nonce: 6)
      result = repository.confirmed_transaction_with_highest_nonce(from: from, chain_id: chain_id)
      expect(result).to be_nil
    end
  end
end
