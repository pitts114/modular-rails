# frozen_string_literal: true

module Arbius
  class BulkBogusAutoMineService
    WAIT_FOR_BULK_SUBMITTED_TASKS_TIMEOUT = ENV.fetch('ARBIUS_WAIT_FOR_BULK_TASKS_TIMEOUT', 60).to_i
    INTERVAL = ENV.fetch('ARBIUS_WAIT_FOR_BULK_TASKS_INTERVAL', 0.5).to_f

    class TimeoutError < StandardError; end

    def initialize(
      bulk_submit_task_service: Arbius::BulkSubmitTaskService.new,
      get_task_ids_service: Arbius::GetTaskIdsFromTaskSubmittedService.new,
      bulk_bogus_mine_service: Arbius::BulkBogusMineService.new,
      transaction_status_service: Ethereum::Public::TransactionStatusService.new,
      arbius_task_submitted_event_model: Arbius::TaskSubmittedEvent,
      wait_for_transaction_service: Arbius::WaitForTransactionService.new,
      poller: Arbius::Polling::Poller.new,
      time: Time,
      kernel: Kernel,
      flipper: Flipper
    )
      @bulk_submit_task_service = bulk_submit_task_service
      @get_task_ids_service = get_task_ids_service
      @bulk_bogus_mine_service = bulk_bogus_mine_service
      @transaction_status_service = transaction_status_service
      @arbius_task_submitted_event_model = arbius_task_submitted_event_model
      @wait_for_transaction_service = wait_for_transaction_service
      @poller = poller
      @time = time
      @kernel = kernel
      @flipper = flipper
    end

    # Submits a task, finds the task id, and bogus mines a solution for it
    # @param from [String] Ethereum address
    # @param model [String] Model hash (bytes32)
    # @param fee [Integer] Fee for the task
    # @param input [Hash] Input data for the task
    def call(from:, model:, fee:, input:, version: 0, owner: nil, n:)
      return [] unless @flipper.enabled?(:bulk_bogus_auto_mine)

      owner ||= from
      ethereum_transaction_id = @bulk_submit_task_service.submit_task(from:, version:, owner:, model:, fee:, input:, n:)

      tx_hash = @wait_for_transaction_service.call(ethereum_transaction_id:)

      time = @time.now

      task_submitted_events = []
      while (@time.now - time) < WAIT_FOR_BULK_SUBMITTED_TASKS_TIMEOUT
        task_submitted_events = @arbius_task_submitted_event_model
          .joins(:arbius_ethereum_event_details)
          .where(arbius_ethereum_event_details: { transaction_hash: tx_hash })
        break if task_submitted_events.count >= n
        @kernel.sleep INTERVAL
      end

      raise TimeoutError, 'No TaskSubmittedEvents found in time' if task_submitted_events.empty?

      @bulk_bogus_mine_service.call(from: from, taskids: task_submitted_events.map(&:task_id))
      task_submitted_events.map(&:task_id)
    end
  end
end
