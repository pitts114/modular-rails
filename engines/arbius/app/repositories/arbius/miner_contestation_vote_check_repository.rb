module Arbius
  class MinerContestationVoteCheckRepository
    class RecordNotUnique < StandardError; end

    # todo: provide a datetime parameter to filter by created_at rather than a seconds parameter
    def self.update_checks!(seconds: 60)
      sql = <<-SQL
        WITH inserted AS (
          INSERT INTO arbius_miner_contestation_vote_checks (task_id, created_at, updated_at)
          SELECT acse.task, NOW(), NOW()
          FROM arbius_contestation_submitted_events acse
          LEFT JOIN arbius_miner_contestation_vote_checks amcvc
            ON amcvc.task_id = acse.task
          WHERE amcvc.task_id IS NULL
            AND acse.created_at < (NOW() - INTERVAL '? seconds')
          RETURNING task_id
        )
        SELECT task_id FROM inserted;
      SQL
      result = ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.send(:sanitize_sql_array, [ sql, seconds ])
      )
      result.rows.flatten
    rescue ActiveRecord::RecordNotUnique => e
      raise RecordNotUnique, "Record already exists: #{e.message}"
    end
  end
end
