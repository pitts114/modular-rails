module Arbius
  class AttackSolutionService
    class OutnumberedError < StandardError; end
    class ContestationEventNotFoundError < StandardError; end
    class SolutionSubmittedEventNotFoundError < StandardError; end
    class AttackSolutionNotFoundError < StandardError; end


    def initialize(
      contestation_vote_repository: Arbius::ContestationVoteRepository,
      miner_model: Arbius::Miner,
      validator_repository: ValidatorRepository.new,
      sent_contestation_vote_repository: Arbius::SentContestationVoteRepository.new,
      vote_on_contestation_job: Arbius::VoteOnContestationJob,
      miner_contestation_vote_check_model: Arbius::MinerContestationVoteCheck,
      random: Random,
      attack_solution_model: Arbius::AttackSolution,
      solution_submitted_event_model: Arbius::SolutionSubmittedEvent,
      address_shuffle_service: Arbius::AddressShuffleService.new,
      alert_outnumbered_job: Arbius::AlertOutnumberedJob,
      feature_flag: Flipper,
      shutdown_service: Arbius::ShutdownService.new,
      validator_model: Arbius::Validator
    )
      @contestation_vote_repository = contestation_vote_repository
      @miner_model = miner_model
      @validator_repository = validator_repository
      @sent_contestation_vote_repository = sent_contestation_vote_repository
      @vote_on_contestation_job = vote_on_contestation_job
      @miner_contestation_vote_check_model = miner_contestation_vote_check_model
      @random = random
      @attack_solution_model = attack_solution_model
      @solution_submitted_event_model = solution_submitted_event_model
      @address_shuffle_service = address_shuffle_service
      @alert_outnumbered_job = alert_outnumbered_job
      @feature_flag = feature_flag
      @shutdown_service = shutdown_service
      @validator_model = validator_model
    end

    def call(task_id:, add_temporary_vote: true)
      # Return early if the 'attack solution' feature flag is disabled
      unless @feature_flag.enabled?(:attack_solution)
        Rails.logger.info("[AttackSolutionService] 'attack solution' feature flag is disabled for task #{task_id}")
        return
      end

      arbius_attack_solution = @attack_solution_model.find_by(task: task_id)
      unless arbius_attack_solution
        Rails.logger.error("[AttackSolutionService] No attack solution record found for task #{task_id} in AttackSolutionService")
        raise AttackSolutionNotFoundError, "No attack solution record found for task #{task_id}"
      end

      arbius_solution_submitted_event = @solution_submitted_event_model.find_by(task: task_id)
      raise SolutionSubmittedEventNotFoundError, "No solution submitted event found for task #{task_id}" unless arbius_solution_submitted_event

      # Don't contest our own solution from our miners or validators.
      arbius_miner = @miner_model.find_by(address: arbius_solution_submitted_event.address)
      arbius_validator = @validator_model.find_by(address: arbius_solution_submitted_event.address)
      return if arbius_miner.present? || arbius_validator.present?

      # might need to update the repository? maybe not
      votes = @contestation_vote_repository.votes_for_task(task_id: arbius_solution_submitted_event.task)
      total_yea_votes = votes.count { |_, yea| yea }
      total_nay_votes = votes.count { |_, yea| !yea }
      nay_voters = votes.select { |_, yea| !yea }.map(&:first)
      yea_voters = votes.select { |address, yea| yea }.map(&:first)

      # account for the automatic vote that the miner should cast that we may not have record of yet.
      total_nay_votes += 1 if assume_automatic_miner_vote?(nay_voters:, task_id:, arbius_solution_submitted_event:)

      return unless total_yea_votes <= total_nay_votes

      new_yay_votes_needed_to_win = total_nay_votes - total_yea_votes + 1

      validators_that_can_vote = @validator_repository.find_addresses_excluding(exclude_addresses: yea_voters)

      if validators_that_can_vote.count < new_yay_votes_needed_to_win
        @alert_outnumbered_job.perform_later
        # Disable 'attack solution' feature flag so that the job doesn't run again.
        @shutdown_service.call
        raise OutnumberedError, "Not enough validators to attack the solution"
      end

      # randomizes based on randomness of the task_id so that racing jobs pick the same validators.
      # picking the same validators wil cause repository.insert_votes! to fail for racing jobs.
      validators_that_can_vote = @address_shuffle_service.shuffle(addresses: validators_that_can_vote, task_id: task_id)

      voters = validators_that_can_vote[0, new_yay_votes_needed_to_win]

      begin
        @sent_contestation_vote_repository.insert_votes!(
          task: arbius_solution_submitted_event.task,
          addresses: voters,
          yea: true
        )
      rescue Arbius::SentContestationVoteRepository::NotUniqueError # we're racing with another attack solution job.
        return
      end

      voters.each { |address| @vote_on_contestation_job.perform_later(arbius_solution_submitted_event.task, address, true) }
    end

    private

    # return true if the miner isn't already voting nay and there is not a check for this task_id yet.
    def assume_automatic_miner_vote?(nay_voters:, task_id:, arbius_solution_submitted_event:)
      nay_voters.exclude?(arbius_solution_submitted_event.address) && !@miner_contestation_vote_check_model.exists?(task_id:)
    end
  end
end
