# frozen_string_literal: true

module Arbius
  class SubmitSolutionService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    # Calls the EngineContract's submit_solution method
    # @param from [String] Ethereum address submitting the solution
    # @param taskid [String] Task hash (bytes32)
    # @param cid [String] IPFS CID as bytes
    def call(from:, taskid:, cid:)
      context = { class: 'Arbius::SubmitSolutionService', task_id: taskid, from: }
      @engine_contract.submit_solution(from:, taskid:, cid:, context:)
    end
  end
end
