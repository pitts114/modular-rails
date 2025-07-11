module Arbius
  class TransactionStatusUpdateHandler
    def initialize(job: Arbius::TransactionStatusUpdateJob)
      @job = job
    end

    def call(payload:)
      @job.perform_later(payload.to_json)
    end
  end
end
