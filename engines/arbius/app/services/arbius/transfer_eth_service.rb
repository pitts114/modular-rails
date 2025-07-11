module Arbius
  class TransferEthService
    def initialize(
      eth_transfer_service: Ethereum::Public::EthTransferService.new,
      miner_model: Arbius::Miner,
      validator_model: Arbius::Validator
    )
      @eth_transfer_service = eth_transfer_service
      @miner_model = miner_model
      @validator_model = validator_model
    end

    # Transfers ETH from one address to another
    # @param from [String] The Ethereum address of the sender
    # @param recipient [String] The Ethereum address of the recipient
    # @param amount [Numeric] The amount of ETH to transfer (in wei)
    def call(from:, recipient:, amount:)
      validate_addresses!(from:, recipient:)
      validate_amount!(amount:)

      @eth_transfer_service.send_eth(from:, to: recipient, amount:)
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
