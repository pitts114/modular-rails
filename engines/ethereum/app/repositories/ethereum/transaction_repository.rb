# frozen_string_literal: true

module Ethereum
  class TransactionRepository
    # Yields the oldest pending transaction for the given from and chain_id, locked in a transaction
    def with_locked_pending_transaction(from:, chain_id:)
      Ethereum::Transaction.transaction do
        tx = Ethereum::Transaction.lock(true)
          .where(from:, chain_id:, status: 'pending')
          .order(created_at: :asc)
          .first
        yield tx if block_given?
      end
    end

    # Returns the confirmed transaction with the highest nonce for the given from and chain_id
    def confirmed_transaction_with_highest_nonce(from:, chain_id:)
      Ethereum::Transaction
        .where(from:, chain_id:, status: 'confirmed')
        .order(nonce: :desc)
        .first
    end
  end
end
