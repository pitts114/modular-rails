module Arbius
  class SolutionSubmittedHandler
    def initialize(
      job: Arbius::SolutionSubmittedJob,
      high_priority_job: Arbius::HighPrioritySolutionSubmittedJob,
      miner_model: Arbius::Miner
    )
      @job = job
      @high_priority_job = high_priority_job
      @miner_model = miner_model
    end

    def call(payload:)
      if @miner_model.exists?(address: payload[:address])
        @high_priority_job.perform_later(payload.to_json)
      else
        @job.perform_later(payload.to_json)
      end
    end
  end
end
