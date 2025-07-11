module Arbius
  class SolutionClaimedHandler
    def initialize(job: Arbius::SolutionClaimedJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
