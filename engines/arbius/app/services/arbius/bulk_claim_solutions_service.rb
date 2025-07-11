# frozen_string_literal: true

module Arbius
  class BulkClaimSolutionsService
    def initialize(bulk_tasks_contract: Ethereum::Public::BulkTasksContract.new)
      @bulk_tasks_contract = bulk_tasks_contract
    end

    # @param from [String] Ethereum address of the claimer
    # @param taskid [String] Task id (bytes32)
    def call(from:, taskids:, context: nil)
      context ||= {
        class: 'Arbius::BulkClaimSolutionsService',
        task_ids: taskids,
        from: from
      }
      @bulk_tasks_contract.claim_solutions(from:, taskids:, context:)
    end
  end
end
