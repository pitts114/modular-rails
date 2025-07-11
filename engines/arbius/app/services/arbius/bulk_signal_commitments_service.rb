# frozen_string_literal: true

module Arbius
  class BulkSignalCommitmentsService
    def initialize(bulk_tasks_contract: Ethereum::Public::BulkTasksContract.new)
      @bulk_tasks_contract = bulk_tasks_contract
    end

    # Calls the BulkTasksContract's signal_commitment method
    # @param from [String] Ethereum address submitting the commitment
    # @param commitment [String] Commitment hash (bytes32)
    def call(from:, commitments:)
      context = { class: 'Arbius::BulkSignalCommitmentsService', from: }
      @bulk_tasks_contract.bulk_signal_commitment(from:, commitments:, context:)
    end
  end
end
