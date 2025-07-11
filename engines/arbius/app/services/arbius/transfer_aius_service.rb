module Arbius
  class TransferAiusService
    def initialize(
      aius_contract: Ethereum::StandardArbErc20Contract.new(contract_address: AddressProvider.aius_contract_address),
      miner_model: Arbius::Miner,
      validator_model: Arbius::Validator
    )
      @aius_contract = aius_contract
      @miner_model = miner_model
      @validator_model = validator_model
    end

    # Transfers AIUS tokens from one address to another
    # @param from [String] The Ethereum address of the sender
    # @param recipient [String] The Ethereum address of the recipient
    # @param amount [Integer] The amount of AIUS tokens to transfer
    def call(from:, recipient:, amount:)
      validate_addresses!(from:, recipient:)
      validate_amount!(amount:)

      @aius_contract.transfer(from:, recipient:, amount:)
    end

    private

    def validate_addresses!(from:, recipient:)
      miner_addresses = @miner_model.pluck(:address)
      validator_addresses = @validator_model.pluck(:address)

      raise ArgumentError, "Invalid sender address" unless miner_addresses.include?(from) || validator_addresses.include?(from)
      raise ArgumentError, "Invalid recipient address" unless miner_addresses.include?(recipient) || validator_addresses.include?(recipient)
    end

    def validate_amount!(amount:)
      raise ArgumentError, "Amount must be greater than 0" if amount <= 0
    end
  end
end
