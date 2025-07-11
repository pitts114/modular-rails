module Arbius
  class TaskSubmittedHandler
    def initialize(job: Arbius::TaskSubmittedJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
