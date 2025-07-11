module Arbius
  class BulkClaimUncontestedSolutionsService
    def initialize(
      engine_contract: Ethereum::Public::EngineContract.new,
      bulk_claim_solution_service: Arbius::BulkClaimSolutionsService.new,
      repository: Arbius::UncontestedSolutionRepository,
      validator_model: Arbius::Validator,
      time: Time
    )
      @engine_contract = engine_contract
      @bulk_claim_solution_service = bulk_claim_solution_service
      @repository = repository
      @validator_model = validator_model
      @time = time
    end

    def call
      min_time = @engine_contract.min_claim_solution_time
      older_than = @time.now - min_time.to_i
      limit = parse_limit_from_env
      solution_submitted_events = @repository.old_uncontested_solutions(older_than:, limit:)
      validator_addresses = @validator_model.pluck(:address)
      from_address = validator_addresses.sample
      task_ids = solution_submitted_events.map(&:task)
      return if task_ids.empty?

      context = { class: 'Arbius::BulkClaimUncontestedSolutionsService', task_ids: task_ids, from: from_address }
      @bulk_claim_solution_service.call(from: from_address, taskids: task_ids, context:)
    end

    private

    def parse_limit_from_env
      ENV.fetch('BULK_CLAIM_SOLUTIONS_LIMIT', '200').to_i
    end
  end
end
