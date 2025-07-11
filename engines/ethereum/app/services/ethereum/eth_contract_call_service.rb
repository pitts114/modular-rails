# frozen_string_literal: true

require 'eth'

module Ethereum
  class EthContractCallService
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

    # Calls a contract method (write operation)
    # contract_address: address of the contract
    # from: sender address
    # data: ABI-encoded data for the contract call
    # value: amount of ETH to send (optional, default 0)
    def call_contract(contract_address:, from:, data:, value: 0)
      nonce = @eth_client.eth_get_transaction_count(from, "pending")["result"].to_i(16)

      fees = @fee_estimator_service.recommended_fees
      max_fee_per_gas = fees[:max_fee_per_gas]
      max_priority_fee_per_gas = fees[:max_priority_fee_per_gas]

      gas_limit = @gas_limit_service.for_contract_call(
        chain_id: @eth_client.chain_id,
        from: from,
        to: contract_address,
        data: data,
        value: value
      )

      tx = {
        chain_id: @eth_client.chain_id,
        nonce: nonce,
        to: contract_address,
        value: value,
        gas_limit: gas_limit,
        priority_fee: max_priority_fee_per_gas,
        max_gas_fee: max_fee_per_gas,
        access_list: [],
        data: data
      }
      signed_tx = @signer_service.sign_transaction(tx: tx, address: from)
      @broadcast_service.send_transaction(signed_tx: signed_tx)
    rescue => e
      raise Error, "Failed to call contract: #{e.message}"
    end
  end
end
