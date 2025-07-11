# frozen_string_literal: true

module Ethereum
  class GasLimitService
    class UnknownChainIdError < StandardError; end

    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    def call(chain_id:, from:, to:, data:, value:)
      for_contract_call(chain_id:, from:, to:, data:, value:)
    end

    #
    def for_eth_transfer(chain_id:)
      21_000
    end
    # does "for contract call" also work for eth transfers?
    def for_contract_call(chain_id:, from:, to:, data:, value: 0)
      estimate_params = {
        from: from,
        to: to,
        data: data,
        value: value
      }.compact
      response = @eth_client.eth_estimate_gas(estimate_params)

      if response && response["result"]
        gas_limit = response["result"].to_i(16) # Convert hex to integer
        gas_limit
      else
        raise "Failed to estimate gas for contract call: #{response.inspect}"
      end
    rescue StandardError => e
      raise "Failed to estimate gas for contract call: #{e.message}"
    end
  end
end
