# frozen_string_literal: true

require 'eth'

module Ethereum
  module Public
    class TransactionStatusService
      class TransactionNotFoundError < StandardError; end

      def initialize(
        ethereum_transaction_model: Ethereum::Transaction
      )
        @ethereum_transaction_model = ethereum_transaction_model
      end

      def call(ethereum_transaction_id:)
        transaction = @ethereum_transaction_model.find_by(id: ethereum_transaction_id)
        raise TransactionNotFoundError, "Transaction with ID #{ethereum_transaction_id} not found" unless transaction

        {
          from: transaction.from,
          to: transaction.to,
          value: transaction.value,
          chain_id: transaction.chain_id,
          nonce: transaction.nonce,
          data: transaction.data,
          tx_hash: transaction.tx_hash,
          raw_tx: transaction.raw_tx,
          signed_tx: transaction.signed_tx,
          status: transaction.status,
          broadcasted_at: transaction.broadcasted_at,
          confirmed_at: transaction.confirmed_at,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }
      end
    end
  end
end
