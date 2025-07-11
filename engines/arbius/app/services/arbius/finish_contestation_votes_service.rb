module Arbius
  class FinishContestationVotesService
    BUFFER_SECONDS = 30

    def initialize(
      engine_contract: Ethereum::Public::EngineContract.new,
      finish_contestation_vote_service: Arbius::FinishContestationVoteService.new,
      repository: Arbius::SolutionSubmittedEventRepository,
      contestation_vote_repository: Arbius::ContestationVoteRepository,
      validator_model: Arbius::Validator,
      time: Time
    )
      @engine_contract = engine_contract
      @finish_contestation_vote_service = finish_contestation_vote_service
      @repository = repository
      @contestation_vote_repository = contestation_vote_repository
      @validator_model = validator_model
      @time = time
    end

    def call
      min_contestation_vote_period_time = @engine_contract.min_contestation_vote_period_time
      contestation_vote_extension_time = @engine_contract.contestation_vote_extension_time.to_i

      older_than = @time.now - (min_contestation_vote_period_time.to_i + BUFFER_SECONDS)

      solution_submitted_events = @repository.old_contested_solutions(older_than:, per_vote_extension_time: contestation_vote_extension_time)
      solution_submitted_events.concat(@repository.attacked_solutions_with_yea_majority(older_than:, per_vote_extension_time: contestation_vote_extension_time))
      validator_addresses = @validator_model.pluck(:address)

      solution_submitted_events.each do |solution_submitted_event|
        vote_count = @contestation_vote_repository.votes_for_task(task_id: solution_submitted_event.task).count
        from_address = validator_addresses.sample
        @finish_contestation_vote_service.call(from: from_address, solution_submitted_event:, vote_count: vote_count)
      end
    end
  end
end
