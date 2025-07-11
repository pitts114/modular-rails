# frozen_string_literal: true

require 'eth'

module Ethereum
  class EthTransferService
    class Error < StandardError; end

    def initialize(
      eth_client: Ethereum::ClientProvider.client,
      signer_service: Ethereum::TransactionSignerService.new,
      broadcast_service: Ethereum::TransactionBroadcastService.new,
      fee_estimator_service: Ethereum::FeeEstimatorService.new,
      gas_limit_service: Ethereum::GasLimitService.new
    )
      @signer_service = signer_service
      @broadcast_service = broadcast_service
      @fee_estimator_service = fee_estimator_service
      @gas_limit_service = gas_limit_service
      @eth_client = eth_client
    end

    def send_eth(from:, to:, amount:)
      nonce = @eth_client.eth_get_transaction_count(from, "pending")["result"].to_i(16)

      fees = @fee_estimator_service.recommended_fees
      max_fee_per_gas = fees[:max_fee_per_gas]
      max_priority_fee_per_gas = fees[:max_priority_fee_per_gas]

      gas_limit = @gas_limit_service.for_eth_transfer(chain_id: @eth_client.chain_id)

      tx = {
        chain_id: @eth_client.chain_id,
        nonce: nonce,
        to: to,
        value: amount,
        gas_limit: gas_limit, # use chain-aware gas limit
        priority_fee: max_priority_fee_per_gas,
        max_gas_fee: max_fee_per_gas,
        access_list: [],
        data: ''
      }
      signed_tx = @signer_service.sign_transaction(tx: tx, address: from)
      @broadcast_service.send_transaction(signed_tx: signed_tx)
    rescue => e
      raise Error, "Failed to send ETH: #{e.message}"
    end
  end
end
