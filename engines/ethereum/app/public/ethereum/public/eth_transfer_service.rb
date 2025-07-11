# frozen_string_literal: true

require 'eth'

module Ethereum
  module Public
    class EthTransferService
      class Error < StandardError; end

      def initialize(
        eth_client: Ethereum::ClientProvider.client,
        send_transaction_job: Ethereum::SendTransactionJob,
        ethereum_transaction_model: Ethereum::Transaction
      )
        @eth_client = eth_client
        @send_transaction_job = send_transaction_job
        @ethereum_transaction_model = ethereum_transaction_model
      end

      def send_eth(from:, to:, amount:)
        chain_id = @eth_client.chain_id
        ethereum_transaction = @ethereum_transaction_model.create!(
          from: from,
          to: to,
          data: '',
          value: amount,
          status: 'pending',
          chain_id: chain_id
        )
        @send_transaction_job.perform_later(from, chain_id)
        ethereum_transaction.id
      end
    end
  end
end
