module Arbius
  class ContestationVoteFinishService
    def initialize(repository: Arbius::ContestationVoteFinishEventRepository)
      @repository = repository
    end

    def call(payload:)
      attributes = payload.dup
      attributes.delete(:id)
      attributes[:task_id] = payload[:id]
      @repository.save!(attributes:)
    rescue Arbius::ContestationVoteFinishEventRepository::RecordNotUnique
    end
  end
end
