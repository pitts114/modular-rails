module Arbius
  class MarkSolutionForAttackService
    class SolutionSubmittedEventNotFoundError < StandardError; end

    def initialize(
      attack_solution_model: Arbius::AttackSolution,
      solution_submitted_event_model: Arbius::SolutionSubmittedEvent,
      submit_contestation_service: Arbius::SubmitContestationService.new,
      miner_model: Arbius::Miner
    )
      @attack_solution_model = attack_solution_model
      @solution_submitted_event_model = solution_submitted_event_model
      @submit_contestation_service = submit_contestation_service
      @miner_model = miner_model
    end

    def call(task_id:)
      arbius_solution_submitted_event = @solution_submitted_event_model.find_by(task: task_id)
      raise MarkSolutionForAttackService::SolutionSubmittedEventNotFoundError unless arbius_solution_submitted_event

      @attack_solution_model.create!(task: task_id)

      arbius_miner = @miner_model.first
      @submit_contestation_service.call(from: arbius_miner.address, taskid: task_id)
    end
  end
end
