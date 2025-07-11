module Arbius
  class SolutionSubmittedService
    def initialize(repository: Arbius::SolutionSubmittedEventRepository)
      @repository = repository
    end

    def call(payload:)
      @repository.save!(attributes: payload)
    rescue Arbius::SolutionSubmittedEventRepository::RecordNotUnique
    end
  end
end
