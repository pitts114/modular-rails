# frozen_string_literal: true

require 'address_provider'

module Arbius
  class SetupService
    def initialize(
      address_provider: AddressProvider,
      standard_arb_erc20_contract: ::Ethereum::StandardArbErc20Contract,
      engine_contract: Ethereum::Public::EngineContract.new
    )
      @address_provider = address_provider
      @standard_arb_erc20_contract = standard_arb_erc20_contract
      @engine_contract = engine_contract
    end

    # Performs a one-time setup for a wallet by approving the engine contract to spend tokens
    # @param from_address [String] The Ethereum address of the wallet to set up
    # @return [Object] The result of the approve transaction
    def call(validator_address:, deposit_amount:)
      contract_address = @address_provider.aius_contract_address
      spender = @address_provider.engine_contract_address
      amount = 1_000_000 * 10**18 # 1,000,000 tokens with 18 decimals
      contract = @standard_arb_erc20_contract.new(contract_address: contract_address)
      contract.approve(from: validator_address, spender: spender, amount: amount)

      @engine_contract.validator_deposit(
        from: validator_address,
        amount: deposit_amount,
        context: { class: 'Arbius::SetupService', address: validator_address, deposit_amount: deposit_amount }
      ) unless deposit_amount <= 0
    end
  end
end
