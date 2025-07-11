module Arbius
  class CommitmentSignaledService
    def initialize(repository: Arbius::SignalCommitmentEventRepository)
      @repository = repository
    end

    def call(payload:)
      @repository.save!(attributes: payload)
    rescue Arbius::SignalCommitmentEventRepository::RecordNotUnique
    end
  end
end
