module Arbius
  class BulkSubmitTaskService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new, serialize_service: SerializeService.new)
      @engine_contract = engine_contract
      @serialize_service = serialize_service
    end

    # Submits tasks to the Engine contract
    # Arguments: from, version, owner, model, fee, input (input is a Ruby hash)
    def submit_task(from:, version:, owner:, model:, fee:, input:, n:)
      input_hex = @serialize_service.serialize_hash_to_hex(hash: input)
      context = { class: 'Arbius::BulkSubmitTaskService', from:, version:, owner:, model:, fee:, n:, input: input_hex }
      @engine_contract.bulk_submit_task(
        from:,
        version:,
        owner:,
        model:,
        fee:,
        n:,
        input: input_hex,
        context:
      )
    end
  end
end
