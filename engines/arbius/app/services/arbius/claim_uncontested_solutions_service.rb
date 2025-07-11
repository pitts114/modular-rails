module Arbius
  class ClaimUncontestedSolutionsService
    def initialize(
      engine_contract: Ethereum::Public::EngineContract.new,
      claim_solution_service: Arbius::ClaimSolutionService.new,
      repository: Arbius::UncontestedSolutionRepository,
      validator_model: Arbius::Validator,
      time: Time
    )
      @engine_contract = engine_contract
      @claim_solution_service = claim_solution_service
      @repository = repository
      @validator_model = validator_model
      @time = time
    end

    def call
      min_time = @engine_contract.min_claim_solution_time
      older_than = @time.now - min_time.to_i
      solution_submitted_events = @repository.old_uncontested_solutions(older_than:)
      validator_addresses = @validator_model.pluck(:address)
      solution_submitted_events.each do |solution_submitted_event|
        from_address = validator_addresses.sample
        context = { class: 'Arbius::ClaimUncontestedSolutionsService', task_id: solution_submitted_event.task, from: from_address }
        @claim_solution_service.call(from: from_address, taskid: solution_submitted_event.task, context:)
      end
    end
  end
end
