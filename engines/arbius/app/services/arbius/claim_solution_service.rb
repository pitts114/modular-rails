# frozen_string_literal: true

module Arbius
  class ClaimSolutionService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    # @param from [String] Ethereum address of the claimer
    # @param taskid [String] Task id (bytes32)
    def call(from:, taskid:, context: nil)
      context ||= {
        class: 'Arbius::ClaimSolutionService',
        task_id: taskid,
        from: from
      }
      @engine_contract.claim_solution(from:, taskid:, context:)
    end
  end
end
