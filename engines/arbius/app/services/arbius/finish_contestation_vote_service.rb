module Arbius
  class FinishContestationVoteService
    def initialize(
      engine_contract: Ethereum::Public::EngineContract.new
    )
      @engine_contract = engine_contract
    end

    def call(from:, solution_submitted_event:, vote_count:)
      context = { class: 'Arbius::FinishContestationVoteService', task_id: solution_submitted_event.task, from: from }
      @engine_contract.contestation_vote_finish(
        from:,
        taskid: solution_submitted_event.task,
        amnt: vote_count,
        context:
      )
    end
  end
end
