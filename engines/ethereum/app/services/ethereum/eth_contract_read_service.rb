# frozen_string_literal: true

require 'eth'

# maybe dont use this, make a Contract instead.
module Ethereum
  class EthContractReadService
    class Error < StandardError; end

    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    # Reads from a contract (eth_call)
    # contract_address: address of the contract
    # from: sender address (optional, can be nil)
    # data: ABI-encoded data for the contract call
    # block: block tag (default: 'latest')
    def call_contract(contract_address:, data:, from: nil, block: 'latest')
      call_params = {
        to: contract_address,
        data: data
      }
      call_params[:from] = from if from
      # NOTE: eth.rb (and/or your node) expects only one argument for eth_call. Passing a block tag as a second argument causes errors.
      result = @eth_client.eth_call(call_params)
      result['result']
    rescue => e
      raise Error, "Failed to read from contract: #{e.message}"
    end
  end
end
