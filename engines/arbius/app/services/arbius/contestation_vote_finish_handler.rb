module Arbius
  class ContestationVoteFinishHandler
    def initialize(job: Arbius::ContestationVoteFinishJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
