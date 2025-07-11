# frozen_string_literal: true

module Arbius
  class BulkSubmitSolutionsService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    # Calls the EngineContract's submit_solution method
    # @param from [String] Ethereum address submitting the solution
    # @param taskid [String] Task hash (bytes32)
    # @param cid [String] IPFS CID as bytes
    def call(from:, taskids:, cids:)
      context = { class: 'Arbius::BulkSubmitSolutionsService', task_ids: taskids, from: }
      @engine_contract.bulk_submit_solution(from:, taskids:, cids:, context:)
    end
  end
end
