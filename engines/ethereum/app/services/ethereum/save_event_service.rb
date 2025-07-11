module Ethereum
  class SaveEventService
    def initialize(repository: Ethereum::EventRepository, logger: Rails.logger)
      @repository = repository
      @logger = logger
    end

    # Converts log attributes and saves the event
    def call(log:, chain_id:, raw_event:)
      converted_log = {
        address: log.address,
        block_hash: log.block_hash,
        block_number: hex_to_i(log.block_number),
        transaction_hash: log.transaction_hash,
        transaction_index: hex_to_i(log.transaction_index),
        log_index: hex_to_i(log.log_index),
        removed: log.removed,
        data: log.data,
        topics: log.topics,
        chain_id: chain_id,
        raw_event: log
      }
      @repository.save_event!(log: converted_log, chain_id: chain_id, raw_event: log)
    rescue Ethereum::EventRepository::EventAlreadyExists => e
      @logger.error("[SaveEventService] Event already exists: #{e.message}")
    end

    private

    def hex_to_i(val)
      return val if val.is_a?(Integer)
      return nil if val.nil?
      val.to_s.start_with?("0x") ? val.to_i(16) : val.to_i
    end
  end
end
