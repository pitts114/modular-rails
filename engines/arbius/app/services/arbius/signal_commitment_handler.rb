module Arbius
  class SignalCommitmentHandler
    def initialize(job: Arbius::SignalCommitmentJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
