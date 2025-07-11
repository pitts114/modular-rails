module Arbius
  class ContestationSubmittedService
    def initialize(repository: Arbius::ContestationSubmittedEventRepository, defend_solution_job: DefendSolutionJob)
      @defend_solution_job = defend_solution_job
      @repository = repository
    end

    def call(payload:)
      arbius_contestation_submitted_event = begin
        @repository.save!(attributes: payload)
      rescue Arbius::ContestationSubmittedEventRepository::RecordNotUnique
        return
      end

      @defend_solution_job.perform_later(arbius_contestation_submitted_event.task)
    end
  end
end
