module Ethereum
  class MarkEventRemovedService
    def initialize(repository: Ethereum::EventRepository, logger: Rails.logger, save_event_service: SaveEventService.new)
      @repository = repository
      @logger = logger
      @save_event_service = save_event_service
    end

    # Converts log attributes and marks the event as removed
    def call(log:, chain_id:, raw_event:)
      @repository.mark_removed!(
        chain_id:,
        block_hash: log.block_hash,
        log_index: hex_to_i(log.log_index)
      )
    rescue Ethereum::EventRepository::EventNotFound => e
      @logger.error("[EventHandler] Tried to remove event but not found: #{e.message}")
      @save_event_service.call(log:, chain_id:, raw_event:)
    end

    private

    def hex_to_i(val)
      return val if val.is_a?(Integer)
      return nil if val.nil?
      val.to_s.start_with?("0x") ? val.to_i(16) : val.to_i
    end
  end
end
