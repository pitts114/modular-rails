# frozen_string_literal: true

module Arbius
  class JobExecutionTrackerRepository
    class RecordNotFound < StandardError; end

    # Yields the job execution tracker record for the given job_name, locked in a transaction
    def self.with_locked_tracker(job_name:)
      Arbius::JobExecutionTracker.transaction do
        tracker = Arbius::JobExecutionTracker.lock(true)
          .find_by(job_name: job_name)

        # Create the record if it doesn't exist
        unless tracker
          tracker = Arbius::JobExecutionTracker.create!(
            job_name: job_name,
            last_executed_at: Time.current
          )
        end

        yield tracker if block_given?
      end
    rescue ActiveRecord::RecordNotFound => e
      raise RecordNotFound, "Job execution tracker not found: #{e.message}"
    end
  end
end
