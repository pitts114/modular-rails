module Arbius
  class ContestationVoteHandler
    def initialize(job: Arbius::ContestationVoteJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
