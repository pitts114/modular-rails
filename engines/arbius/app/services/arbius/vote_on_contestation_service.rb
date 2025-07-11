# frozen_string_literal: true

module Arbius
  class VoteOnContestationService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    def call(from:, task_id:, yea:)
      context = { class: 'Arbius::VoteOnContestationService', task_id:, from:, yea: }
      @engine_contract.vote_on_contestation(
        from:,
        taskid: task_id,
        yea:,
        context:
      )
    end
  end
end
