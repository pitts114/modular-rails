# frozen_string_literal: true

module Arbius
  class CheckMinerContestationVoteService
    def initialize(
      miner_contestation_vote_check_repository: Arbius::MinerContestationVoteCheckRepository,
      defend_solution_job: Arbius::DefendSolutionJob
    )
      @miner_contestation_vote_check_repository = miner_contestation_vote_check_repository
      @defend_solution_job = defend_solution_job
    end

    def call
      @miner_contestation_vote_check_repository.update_checks!.each do |task_id|
        @defend_solution_job.perform_later(task_id)
      end
    end
  end
end
