module Arbius
  class ValidatorDepositService
    def initialize(
      shutdown_auto_mine_service: Arbius::ShutdownAutoMineService.new,
      alert_validator_deposit_service: Arbius::AlertValidatorDepositService.new,
      flipper: Flipper
    )
      @shutdown_auto_mine_service = shutdown_auto_mine_service
      @alert_validator_deposit_service = alert_validator_deposit_service
      @flipper = flipper
    end

    def call(payload:)
      return unless @flipper.enabled?(:shutdown_on_validator_deposit)

      amount = payload[:amount]

      # what we really want to do is check if there a new validator or if an existing validator's stake
      # is now greater or equal to the minimum. I want to know who all can challenge me at the moment,
      # but not validators that are topping up
      return unless amount && amount >= ENV.fetch('ARBIUS_VALIDATOR_DEPOSIT_ALERT_MINIMUM_WEI', 10 * Eth::Unit::ETHER.to_i).to_i

      @shutdown_auto_mine_service.call
      @alert_validator_deposit_service.call
    end
  end
end
