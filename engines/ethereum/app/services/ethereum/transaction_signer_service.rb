# frozen_string_literal: true

require 'eth'
require 'vault_client'

module Ethereum
  class TransactionSignerService
    class Error < StandardError; end

    def initialize(
      vault_client: VaultClient::VaultClient.new(
        api_secret: ENV.fetch('VAULT_API_SECRET'),
        host: ENV.fetch('VAULT_HOST'),
        port: ENV.fetch('VAULT_PORT')
      ),
        eth_tx_class: Eth::Tx
      )
      @vault_client = vault_client
      @eth_tx_class = eth_tx_class
    end

    def sign_transaction(tx:, address:)
      response = @vault_client.sign_tx(address: address, tx: tx)
      if response['signed_transaction']
        @eth_tx_class.decode(response['signed_transaction'])
      else
        raise Error, "Vault did not return signed_transaction: #{response.inspect}"
      end
    end
  end
end
