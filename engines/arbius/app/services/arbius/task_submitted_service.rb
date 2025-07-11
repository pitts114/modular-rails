module Arbius
  class TaskSubmittedService
    def initialize(repository: Arbius::TaskSubmittedEventRepository)
      @repository = repository
    end

    def call(payload:)
      attributes = payload.dup
      attributes.delete(:id)
      attributes[:task_id] = payload[:id]
      @repository.save!(attributes: attributes)
    rescue Arbius::TaskSubmittedEventRepository::RecordNotUnique
    end
  end
end
