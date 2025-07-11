module Arbius
  class MarkSolutionsForAttackBatchService
    def initialize(
      solution_submitted_event_repository: Arbius::SolutionSubmittedEventRepository,
      mark_solution_for_attack_job: Arbius::MarkSolutionForAttackJob
    )
      @solution_submitted_event_repository = solution_submitted_event_repository
      @mark_solution_for_attack_job = mark_solution_for_attack_job
    end

    def call(count:, addresses:)
      addresses = addresses.map { |address| Eth::Address.new(address).checksummed }
      events = @solution_submitted_event_repository.unattacked_for_addresses(
        addresses: addresses,
        limit: count,
        cutoff_time: (3600 - 60).seconds.ago # 59 minutes ago
      )

      events.each do |event|
        @mark_solution_for_attack_job.perform_later(event.task)
      end
    end
  end
end
