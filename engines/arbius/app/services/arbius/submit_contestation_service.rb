# frozen_string_literal: true

module Arbius
  class SubmitContestationService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    # @param from [String] Ethereum address of the validator
    # @param taskid [String] Task id (bytes32)
    def call(from:, taskid:)
      context = { class: 'Arbius::SubmitContestationService', task_id: taskid, from: }
      @engine_contract.submit_contestation(from:, taskid:, context:)
    end
  end
end
