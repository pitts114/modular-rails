# frozen_string_literal: true

module Ethereum
  class TransactionStatusPublishService
    def initialize(notifications: ActiveSupport::Notifications)
      @notifications = notifications
    end

    def call(ethereum_transaction:)
      return unless ethereum_transaction.status.in?(%w[confirmed failed])

      event_name = "ethereum.transaction_status_updated"
      payload = {
        ethereum_transaction_id: ethereum_transaction.id,
        from: ethereum_transaction.from,
        to: ethereum_transaction.to,
        tx_hash: ethereum_transaction.tx_hash,
        status: ethereum_transaction.status,
        chain_id: ethereum_transaction.chain_id,
        context: ethereum_transaction.context
      }

      @notifications.instrument(event_name, payload)
    end
  end
end
