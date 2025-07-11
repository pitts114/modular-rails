# frozen_string_literal: true

require 'eth'

module Ethereum
  class ContractProvider
    def self.engine
      Eth::Contract.from_abi(
        name: 'Engine',
        address: ENV.fetch("ENGINE_CONTRACT_ADDRESS"),
        abi: JSON.parse(File.read(Rails.root.join("engines/ethereum/abi/engine.json")))
      )
    end
  end
end
