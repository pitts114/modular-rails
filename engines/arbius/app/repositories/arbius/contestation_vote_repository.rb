module Arbius
  class ContestationVoteRepository
    # Returns a hash: { validator_address => vote }
    def self.votes_for_task(task_id:)
      sql = <<-SQL
            SELECT DISTINCT ON (validator_address) validator_address, yea
            FROM (
              SELECT address AS validator_address, yea, 1 AS priority
              FROM arbius_contestation_vote_events
              WHERE task = ?
              UNION ALL
              SELECT address AS validator_address, yea, 2 AS priority
              FROM arbius_sent_contestation_vote_events
              WHERE task = ? AND status IN ('confirmed', 'pending')
            ) AS all_votes
            ORDER BY validator_address, priority
          SQL

      sql = ActiveRecord::Base.send(:sanitize_sql_array, [ sql, task_id, task_id ])

      result = ActiveRecord::Base.connection.exec_query(sql)
      result.to_a.map { |row| [ row['validator_address'], row['yea'] ] }
    end
  end
end
