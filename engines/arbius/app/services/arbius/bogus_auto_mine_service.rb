# frozen_string_literal: true

module Arbius
  class BogusAutoMineService
    def initialize(
      submit_task_service: Arbius::SubmitTaskService.new,
      get_task_ids_service: Arbius::GetTaskIdsFromTaskSubmittedService.new,
      bogus_mine_service: Arbius::BogusMineService.new,
      transaction_status_service: Ethereum::Public::TransactionStatusService.new,
      arbius_task_submitted_event_model: Arbius::TaskSubmittedEvent,
      wait_for_transaction_service: Arbius::WaitForTransactionService.new,
      poller: Arbius::Polling::Poller.new
    )
      @submit_task_service = submit_task_service
      @get_task_ids_service = get_task_ids_service
      @bogus_mine_service = bogus_mine_service
      @transaction_status_service = transaction_status_service
      @arbius_task_submitted_event_model = arbius_task_submitted_event_model
      @wait_for_transaction_service = wait_for_transaction_service
      @poller = poller
    end

    # Submits a task, finds the task id, and bogus mines a solution for it
    # @param from [String] Ethereum address
    # @param model [String] Model hash (bytes32)
    # @param fee [Integer] Fee for the task
    # @param input [Hash] Input data for the task
    def call(from:, model:, fee:, input:, version: 0, owner: nil)
      owner ||= from
      ethereum_transaction_id = @submit_task_service.submit_task(from:, version:, owner:, model:, fee:, input:)

      tx_hash = @wait_for_transaction_service.call(ethereum_transaction_id:)

      begin
        event = @poller.poll do
          @arbius_task_submitted_event_model
            .joins(:arbius_ethereum_event_details)
            .where(arbius_ethereum_event_details: { transaction_hash: tx_hash })
            .first
        end
      rescue Arbius::Polling::Poller::TimeoutError
        raise 'TaskSubmittedEvent not found in time'
      end

      @bogus_mine_service.call(from: from, taskid: event.task_id)
      event.task_id
    end
  end
end
