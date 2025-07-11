module Arbius
  class SolutionClaimedService
    def initialize(repository: Arbius::SolutionClaimedEventRepository)
      @repository = repository
    end

    def call(payload:)
      @repository.save!(attributes: payload)
    rescue Arbius::SolutionClaimedEventRepository::RecordNotUnique
    end
  end
end
