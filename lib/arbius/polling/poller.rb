# frozen_string_literal: true

module Arbius
  module Polling
    class Poller
      def initialize(max_attempts: 60, interval: 1)
        @max_attempts = max_attempts
        @interval = interval
      end

      # Yields to the block, returns the result if not nil, or retries up to max_attempts
      # Retries if block raises ActiveRecord::RecordNotFound
      # Raises TimeoutError if not found in time
      def poll
        @max_attempts.times do
          begin
            result = yield
            return result if result
          rescue ActiveRecord::RecordNotFound
            # continue polling
          end
          sleep @interval
        end
        raise TimeoutError, "Polling timed out without finding a result"
      end

      class TimeoutError < StandardError; end
    end
  end
end
