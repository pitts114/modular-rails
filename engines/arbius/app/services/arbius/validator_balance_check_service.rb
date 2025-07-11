# frozen_string_literal: true

module Arbius
  class ValidatorBalanceCheckService
    MINIMUM_PERCENTAGE_THRESHOLD = 1.03 # 103% of minimum

    def initialize(
      engine_contract: Ethereum::Public::EngineContract.new,
      validator_model: Arbius::Validator,
      miner_model: Arbius::Miner,
      sentry: Sentry,
      logger: Rails.logger
    )
      @engine_contract = engine_contract
      @validator_model = validator_model
      @miner_model = miner_model
      @sentry = sentry
      @logger = logger
    end

    def call
      validator_minimum = @engine_contract.get_validator_minimum
      @logger.info("Validator minimum: #{validator_minimum}")
      return if validator_minimum.zero?

      threshold = (validator_minimum * MINIMUM_PERCENTAGE_THRESHOLD).to_i
      @logger.info("Threshold for deposits: #{threshold}")

      check_validators(threshold)
      check_miners(threshold)
    rescue StandardError => e
      @sentry.capture_exception(e, extra: { service: 'ValidatorBalanceCheckService' })
      @logger.error("Exception in ValidatorBalanceCheckService: #{e.class}: #{e.message}")
      raise
    end

    private

    def check_validators(threshold)
      @validator_model.find_each do |validator|
        check_address_balance(address: validator.address, threshold: threshold, type: 'validator')
      end
    end

    def check_miners(threshold)
      @miner_model.find_each do |miner|
        check_address_balance(address: miner.address, threshold: threshold, type: 'miner')
      end
    end

    def check_address_balance(address:, threshold:, type:)
      deposit = @engine_contract.get_validator_deposit(address: address)
      @logger.info("Checking #{type} address=#{address}, deposit=#{deposit}, threshold=#{threshold}")
      return if deposit.nil?

      if deposit < threshold
        @logger.warn("#{type.capitalize} (#{address}) deposit (#{deposit}) is below threshold (#{threshold})")
        @sentry.capture_message(
          "#{type.capitalize} deposit below threshold",
          extra: {
            address: address,
            current_deposit: deposit,
            threshold: threshold,
            type: type
          },
          level: :warning
        )
      else
        @logger.info("#{type.capitalize} (#{address}) deposit (#{deposit}) meets threshold (#{threshold})")
      end
    rescue StandardError => e
      @sentry.capture_exception(e, extra: {
        service: 'ValidatorBalanceCheckService',
        address: address,
        type: type
      })
      @logger.error("Exception checking #{type} (#{address}): #{e.class}: #{e.message}")
      # Continue processing other addresses even if one fails
    end
  end
end
