# frozen_string_literal: true

module Arbius
  class GetTaskIdsFromTaskSubmittedService
    TASK_SUBMITTED_EVENT_SIG = '0xc3d3e0544c80e3bb83f62659259ae1574f72a91515ab3cae3dd75cf77e1b0aea'

    def initialize(receipt_service: Ethereum::TransactionReceiptService.new)
      @receipt_service = receipt_service
    end

    # Returns an array of task IDs from TaskSubmitted events in the transaction
    # @param tx_hash [String] the transaction hash
    # @return [Array<String>] the task IDs
    def call(tx_hash:)
      receipt = @receipt_service.fetch(tx_hash: tx_hash)
      return raise 'No logs found in transaction receipt' unless receipt && receipt['logs']

      task_ids = receipt['logs'].select { |log|
        log['topics'] && log['topics'].first == TASK_SUBMITTED_EVENT_SIG
      }.map { |log|
        # The task ID is the 2nd topic (index 1)
        log['topics'][1]
      }.compact

      raise 'No TaskSubmitted events found in transaction' if task_ids.empty?
      task_ids
    end
  end
end
