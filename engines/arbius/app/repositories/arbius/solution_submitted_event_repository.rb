module Arbius
  class SolutionSubmittedEventRepository
    class RecordNotUnique < StandardError; end
    class RecordInvalid < StandardError; end

    # Returns an array of SolutionSubmittedEvent records that are older than the given since time,
    # have a related ContestationSubmittedEvent (by task),
    # are submitted by an address present in the miners table,
    # do NOT have a related ContestationVoteFinishEvent (by task),
    # do NOT have more yea votes than nay votes (nays win ties),
    # and are older than the extension time added by each related contestation vote.
    def self.old_contested_solutions(older_than:, per_vote_extension_time:)
      # Subquery to count yea and nay votes per task
      vote_counts = <<-SQL
        SELECT task,
          SUM(CASE WHEN yea THEN 1 ELSE 0 END) AS yea_count,
          SUM(CASE WHEN yea THEN 0 ELSE 1 END) AS nay_count,
          COUNT(*) AS total_votes
        FROM arbius_contestation_vote_events
        GROUP BY task
      SQL

      query = Arbius::SolutionSubmittedEvent
        .joins("INNER JOIN arbius_miners ON arbius_miners.address = arbius_solution_submitted_events.address")
        .joins("INNER JOIN arbius_contestation_submitted_events ON arbius_contestation_submitted_events.task = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN arbius_contestation_vote_finish_events ON arbius_contestation_vote_finish_events.task_id = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN (#{vote_counts}) AS vote_counts ON vote_counts.task = arbius_solution_submitted_events.task")
        .where("arbius_contestation_submitted_events.created_at <= (?::timestamp - COALESCE(vote_counts.total_votes, 0) * (? || ' seconds')::interval)", older_than, per_vote_extension_time)
        .where('arbius_contestation_vote_finish_events.id IS NULL')
        .where('(vote_counts.yea_count IS NULL OR vote_counts.yea_count <= vote_counts.nay_count)')

      query.to_a
    end

    def self.save!(attributes:)
      Arbius::ApplicationRecord.transaction do
        arbius_ethereum_event_detail = Arbius::EthereumEventDetail.create!(
          ethereum_event_id: attributes[:ethereum_event_id],
          block_hash: attributes[:block_hash],
          block_number: attributes[:block_number],
          chain_id: attributes[:chain_id],
          contract_address: attributes[:contract_address],
          transaction_hash: attributes[:transaction_hash],
          transaction_index: attributes[:transaction_index]
        )
        Arbius::SolutionSubmittedEvent.create!(
          address: attributes[:address],
          task: attributes[:task],
          arbius_ethereum_event_details_id: arbius_ethereum_event_detail.id
        )
      rescue ActiveRecord::RecordNotUnique => e
        raise RecordNotUnique, "Record already exists: #{e.message}"
      rescue ActiveRecord::RecordInvalid => e
        raise RecordInvalid, "Record is invalid: #{e.message}"
      end
    end

    # Returns up to `limit` SolutionSubmittedEvent records for the given addresses, ordered oldest to newest,
    # where created_at is before `cutoff_time`, there is no AttackSolution for the same task,
    # and the address is not a miner or validator (using efficient LEFT JOIN anti-joins).
    def self.unattacked_for_addresses(addresses:, limit:, cutoff_time:)
      return [] if addresses.blank? || limit.to_i <= 0

      Arbius::SolutionSubmittedEvent
        .where(address: addresses)
        .where('arbius_solution_submitted_events.created_at > ?', cutoff_time)
        .joins("LEFT JOIN arbius_attack_solutions ON arbius_attack_solutions.task = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN arbius_miners ON arbius_miners.address = arbius_solution_submitted_events.address")
        .joins("LEFT JOIN arbius_validators ON arbius_validators.address = arbius_solution_submitted_events.address")
        .where('arbius_attack_solutions.task IS NULL')
        .where('arbius_miners.address IS NULL')
        .where('arbius_validators.address IS NULL')
        .order('arbius_solution_submitted_events.created_at ASC')
        .limit(limit)
        .to_a
    end

    # Returns SolutionSubmittedEvent records that have a related AttackSolution event (by task),
    # a related ContestationSubmittedEvent (by task),
    # do NOT have a related ContestationVoteFinishEvent (by task),
    # where the yea votes exceed the nay votes (yea > nay),
    # and are older than the given older_than time, factoring in per_vote_extension_time per vote.
    def self.attacked_solutions_with_yea_majority(older_than:, per_vote_extension_time:)
      vote_counts = <<-SQL
        SELECT task,
          SUM(CASE WHEN yea THEN 1 ELSE 0 END) AS yea_count,
          SUM(CASE WHEN yea THEN 0 ELSE 1 END) AS nay_count,
          COUNT(*) AS total_votes
        FROM arbius_contestation_vote_events
        GROUP BY task
      SQL

      query = Arbius::SolutionSubmittedEvent
        .joins("INNER JOIN arbius_attack_solutions ON arbius_attack_solutions.task = arbius_solution_submitted_events.task")
        .joins("INNER JOIN arbius_contestation_submitted_events ON arbius_contestation_submitted_events.task = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN arbius_contestation_vote_finish_events ON arbius_contestation_vote_finish_events.task_id = arbius_solution_submitted_events.task")
        .joins("LEFT JOIN (#{vote_counts}) AS vote_counts ON vote_counts.task = arbius_solution_submitted_events.task")
        .where("arbius_contestation_submitted_events.created_at <= (?::timestamp - COALESCE(vote_counts.total_votes, 0) * (? || ' seconds')::interval)", older_than, per_vote_extension_time)
        .where('arbius_contestation_vote_finish_events.id IS NULL')
        .where('vote_counts.yea_count > vote_counts.nay_count')

      query.to_a
    end
  end
end
