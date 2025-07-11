module Arbius
  class UncontestedSolutionRepository
    # Returns an array of SolutionSubmittedEvent records that are older than the given since time,
    # have no related ContestationSubmittedEvent or SolutionClaimedEvent (by task_id),
    # and are submitted by an address present in the miners table.
    def self.old_uncontested_solutions(older_than:, limit: nil)
      query = Arbius::SolutionSubmittedEvent
        .joins("INNER JOIN arbius_miners ON arbius_miners.address = arbius_solution_submitted_events.address")
        .joins("LEFT JOIN arbius_contestation_submitted_events ON arbius_contestation_submitted_events.task = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN arbius_solution_claimed_events ON arbius_solution_claimed_events.task = arbius_solution_submitted_events.task")
        .where('arbius_solution_submitted_events.created_at <= ?', older_than)
        .where('arbius_contestation_submitted_events.id IS NULL')
        .where('arbius_solution_claimed_events.id IS NULL')

      query = query.limit(limit) if limit
      query.to_a
    end
  end
end
