module Arbius
  class ValidatorDepositHandler
    def initialize(job: Arbius::ValidatorDepositJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
