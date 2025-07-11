# frozen_string_literal: true

module Arbius
  class WaitForTransactionService
    DEFAULT_TIMEOUT = ENV.fetch('ARBIUS_WAIT_FOR_TRANSACTION_TIMEOUT').to_i
    DEFAULT_INTERVAL = ENV.fetch('ARBIUS_WAIT_FOR_TRANSACTION_INTERVAL').to_i
    class TimeoutError < StandardError; end

    # Initializes the service with dependencies
    # @param transaction_status_service [Ethereum::Public::TransactionStatusService]
    # @param time [Time] allows mocking time in tests

    def initialize(transaction_status_service: Ethereum::Public::TransactionStatusService.new, time: Time)
      @transaction_status_service = transaction_status_service
      @time = time
    end

    # Waits for a transaction to be confirmed
    # @param ethereum_transaction_id [String]
    # @param timeout [Integer] seconds to wait before giving up
    # @param interval [Integer] seconds between status checks
    # @return [String] tx_hash if confirmed
    # @raise [RuntimeError] if not confirmed in time
    def call(ethereum_transaction_id:, timeout: DEFAULT_TIMEOUT, interval: DEFAULT_INTERVAL)
      start_time = @time.now
      loop do
        ActiveRecord::Base.connection.clear_query_cache # this sucks
        result = @transaction_status_service.call(ethereum_transaction_id: ethereum_transaction_id)
        return result[:tx_hash] if result[:status] == 'confirmed'
        break if @time.now - start_time >= timeout
        sleep interval
      end
      raise TimeoutError, 'Transaction not confirmed in time'
    end
  end
end
