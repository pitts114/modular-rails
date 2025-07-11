# frozen_string_literal: true

module Arbius
  class WaiBulkBogusAutoMineSchedulerService
    JOB_NAME = 'WaiBulkBogusAutoMineJob'

    def initialize(
      job_execution_tracker_repository: Arbius::JobExecutionTrackerRepository,
      time: Time
    )
      @job_execution_tracker_repository = job_execution_tracker_repository
      @time = time
    end

    def call
      @job_execution_tracker_repository.with_locked_tracker(job_name: JOB_NAME) do |tracker|
        time_since_last_execution = @time.current - tracker.last_executed_at
        interval_seconds = ENV.fetch('ARBIUS_WAI_BULK_BOGUS_AUTO_MINE_INTERVAL_SECONDS', '3600').to_i

        if time_since_last_execution >= interval_seconds
          tracker.update!(last_executed_at: @time.current)
          Arbius::WaiBulkBogusAutoMineJob.perform_later
        end
      end
    end
  end
end
