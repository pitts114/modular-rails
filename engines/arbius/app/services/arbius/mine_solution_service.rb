# frozen_string_literal: true

module Arbius
  class MineSolutionService
    def initialize(
      generate_commitment_service: Arbius::GenerateCommitmentService.new,
      signal_commitment_service: Arbius::SignalCommitmentService.new,
      submit_solution_service: Arbius::SubmitSolutionService.new,
      wait_for_transaction_service: Arbius::WaitForTransactionService.new
    )
      @generate_commitment_service = generate_commitment_service
      @signal_commitment_service = signal_commitment_service
      @submit_solution_service = submit_solution_service
      @wait_for_transaction_service = wait_for_transaction_service
    end

    # Mines a solution by generating a commitment, signaling it, and submitting the solution
    # @param from [String] Ethereum address submitting the solution
    # @param taskid [String] Task hash (bytes32)
    # @param cid [String] IPFS CID as bytes
    def call(from:, taskid:, cid:)
      commitment = @generate_commitment_service.generate_commitment_onchain(sender: from, taskid: taskid, cid: cid)
      ethereum_transaction_id = @signal_commitment_service.call(from: from, commitment: commitment)
      @wait_for_transaction_service.call(ethereum_transaction_id:)

      ethereum_transaction_id = @submit_solution_service.call(from: from, taskid: taskid, cid: cid)
      @wait_for_transaction_service.call(ethereum_transaction_id:)
    end
  end
end
