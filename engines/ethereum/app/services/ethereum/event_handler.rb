module Ethereum
  class EventHandler
    def initialize(logger: Rails.logger, mark_event_removed_service: MarkEventRemovedService.new, save_event_service: SaveEventService.new)
      @logger = logger
      @mark_event_removed_service = mark_event_removed_service
      @save_event_service = save_event_service
    end

    # Handles Ethereum event logs
    # @param log [Hash] the event log hash from Ethereum
    def call(log:, chain_id:, raw_event:)
      @logger.info("[EventHandler] Handling Ethereum event: \n#{log.inspect}")

      if log.removed
        @mark_event_removed_service.call(log: log, chain_id: chain_id, raw_event: raw_event)
      else
        @save_event_service.call(log: log, chain_id: chain_id, raw_event: raw_event)
      end
    end
  end
end
