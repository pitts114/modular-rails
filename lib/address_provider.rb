# frozen_string_literal: true

require "eth"

module AddressProvider
  module_function

  def aius_contract_address
    checksummed_address(ENV.fetch("AIUS_CONTRACT_ADDRESS"))
  end

  def engine_contract_address
    checksummed_address(ENV.fetch("ENGINE_CONTRACT_ADDRESS"))
  end

  def bulk_tasks_contract_address
    checksummed_address(ENV.fetch("BULK_TASKS_CONTRACT_ADDRESS"))
  end

  def checksummed_address(address)
    Eth::Address.new(address).checksummed
  end
end
