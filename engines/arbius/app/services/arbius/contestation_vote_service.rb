module Arbius
  class ContestationVoteService
    class SolutionSubmittedEventNotFoundError < StandardError; end

    def initialize(
      repository: Arbius::ContestationVoteEventRepository,
      validator_model: Arbius::Validator,
      miner_model: Arbius::Miner,
      attack_solution_model: Arbius::AttackSolution,
      attack_solution_job: Arbius::AttackSolutionJob,
      defend_solution_job: Arbius::DefendSolutionJob,
      solution_submitted_event_model: Arbius::SolutionSubmittedEvent
    )
      @validator_model = validator_model
      @miner_model = miner_model
      @repository = repository
      @attack_solution_model = attack_solution_model
      @attack_solution_job = attack_solution_job
      @defend_solution_job = defend_solution_job
      @solution_submitted_event_model = solution_submitted_event_model
    end

    def call(payload:)
      arbius_contestation_vote_event = begin
        @repository.save!(attributes: payload)
      rescue Arbius::ContestationVoteEventRepository::RecordNotUnique
        return
      end
      task = arbius_contestation_vote_event.task

      arbius_solution_submitted_event = @solution_submitted_event_model.find_by(task:)
      raise SolutionSubmittedEventNotFoundError, "Solution submitted event not found for task: #{task}" unless arbius_solution_submitted_event

      if defend?(arbius_solution_submitted_event:)
        @defend_solution_job.perform_later(task)
      elsif attack?(arbius_solution_submitted_event:)
        @attack_solution_job.perform_later(task)
      end
    end

    private

    def defend?(arbius_solution_submitted_event:)
      @miner_model.find_by(address: arbius_solution_submitted_event.address).present?
    end

    def attack?(arbius_solution_submitted_event:)
      @attack_solution_model.find_by(task: arbius_solution_submitted_event.task).present?
    end
  end
end
