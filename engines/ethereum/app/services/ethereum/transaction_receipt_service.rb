# frozen_string_literal: true

module Ethereum
  class TransactionReceiptService
    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    # Returns the transaction receipt for a given transaction hash
    # @param tx_hash [String] the transaction hash
    # @return [Hash, nil] the transaction receipt or nil if not found
    def fetch(tx_hash:)
      response = @eth_client.eth_get_transaction_receipt(tx_hash)
      response && response["result"]
    rescue StandardError => e
      raise "Failed to fetch transaction receipt: #{e.message}"
    end
  end
end
