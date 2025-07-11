module Arbius
  class SubmitTaskService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new, serialize_service: SerializeService.new)
      @engine_contract = engine_contract
      @serialize_service = serialize_service
    end

    # Submits a task to the Engine contract
    # Arguments: from, version, owner, model, fee, input (input is a Ruby hash)
    def submit_task(from:, version:, owner:, model:, fee:, input:)
      input_hex = @serialize_service.serialize_hash_to_hex(hash: input)
      context = { class: 'Arbius::SubmitTaskService', from:, version:, owner:, model:, fee:, input: input_hex }
      @engine_contract.submit_task(
        from: from,
        version: version,
        owner: owner,
        model: model,
        fee: fee,
        input: input_hex,
        context:
      )
    end
  end
end
