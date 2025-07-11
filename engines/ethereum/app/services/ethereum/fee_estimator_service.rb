# frozen_string_literal: true

module Ethereum
  class FeeEstimatorService
    class Error < StandardError; end

    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    def recommended_fees(base_fee_factor: 2, alternative_max_priority_fee_per_gas: 1_000_000_000)
      block = @eth_client.eth_get_block_by_number('latest', false)
      base_fee_per_gas = block.dig('result', 'baseFeePerGas')&.to_i(16)
      raise Error, 'Could not fetch baseFeePerGas from latest block' unless base_fee_per_gas

      begin
        max_priority_fee_per_gas = @eth_client.eth_max_priority_fee_per_gas['result']&.to_i(16)
      rescue
        max_priority_fee_per_gas = nil
      end
      max_priority_fee_per_gas ||= alternative_max_priority_fee_per_gas

      max_fee_per_gas = base_fee_per_gas * base_fee_factor + max_priority_fee_per_gas

      {
        max_fee_per_gas: max_fee_per_gas,
        max_priority_fee_per_gas: max_priority_fee_per_gas
      }
    rescue => e
      raise Error, "Failed to estimate fees: #{e.message}"
    end
  end
end
