module Ethereum
  class MarkEventFinalizedService
    def initialize(repository: Ethereum::EventRepository)
      @repository = repository
    end

    def call(ethereum_event:)
      @repository.mark_finalized!(
        chain_id: ethereum_event.chain_id,
        block_hash: ethereum_event.block_hash,
        log_index: ethereum_event.log_index
      )
    end
  end
end
