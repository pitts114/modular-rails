# frozen_string_literal: true

module Arbius
  class BulkMineSolutionService
    class LengthMismatchError < StandardError; end

    def initialize(
      generate_commitment_service: Arbius::GenerateCommitmentService.new,
      bulk_signal_commitments_service: Arbius::BulkSignalCommitmentsService.new,
      bulk_submit_solutions_service: Arbius::BulkSubmitSolutionsService.new,
      wait_for_transaction_service: Arbius::WaitForTransactionService.new
    )
      @generate_commitment_service = generate_commitment_service
      @bulk_signal_commitments_service = bulk_signal_commitments_service
      @bulk_submit_solutions_service = bulk_submit_solutions_service
      @wait_for_transaction_service = wait_for_transaction_service
    end

    # Mines a solution by generating commitments and submitting them
    # @param from [String] Ethereum address submitting the solution
    # @param taskids [Array<String>] Array of task hashes (bytes32)
    # @param cids [Array<String>] Array of IPFS CIDs as bytes
    # @return [String] Ethereum transaction ID of the bulk submission
    def call(from:, taskids:, cids:)
      raise LengthMismatchError, 'taskids and cids must have the same length' unless taskids.length == cids.length

      commitments = taskids.zip(cids).map do |taskid, cid|
        @generate_commitment_service.generate_commitment(sender: from, taskid: taskid, cid: cid)
      end
      ethereum_transaction_id = @bulk_signal_commitments_service.call(from: from, commitments: commitments)
      @wait_for_transaction_service.call(ethereum_transaction_id: ethereum_transaction_id)

      ethereum_transaction_id = @bulk_submit_solutions_service.call(from: from, taskids: taskids, cids: cids)
      @wait_for_transaction_service.call(ethereum_transaction_id: ethereum_transaction_id)
    end
  end
end
