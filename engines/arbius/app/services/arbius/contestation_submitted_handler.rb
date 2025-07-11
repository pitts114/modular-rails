module Arbius
  class ContestationSubmittedHandler
    def initialize(job: Arbius::ContestationSubmittedJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
