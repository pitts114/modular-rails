module Ethereum
  class EventRepository
    class EventNotFound < StandardError; end
    class EventAlreadyExists < StandardError; end
    class EventFinalized < StandardError; end

    # Find events that are not finalized and are older than the given block number
    # @param chain_id [Integer] the chain id
    # @param block_number [Integer] the block number threshold
    # @return [ActiveRecord::Relation] events not finalized and older than block_number
    def self.unfinalized_older_than(chain_id:, block_number:)
      Ethereum::Event.where(chain_id: chain_id)
                     .where(finalized: false)
                     .where('block_number < ?', block_number)
    end

    # Save a new event and its topics
    # @param log [Hash] the event log hash from Ethereum
    # @param chain_id [Integer] the chain id
    # @param raw_event [Hash] the original log hash (optional, for explicit override)
    def self.save_event!(log:, chain_id:, raw_event:)
      ActiveRecord::Base.transaction do
        event = Ethereum::Event.create!(
          chain_id: chain_id,
          address: log[:address],
          block_hash: log[:block_hash],
          block_number: log[:block_number],
          transaction_hash: log[:transaction_hash],
          transaction_index: log[:transaction_index],
          log_index: log[:log_index],
          removed: log[:removed] || false,
          data: log[:data],
          finalized: log[:finalized] || false,
          raw_event: raw_event
        )
        (log[:topics] || []).each_with_index do |topic, i|
          event.ethereum_event_topics.create!(topic: topic, topic_index: i)
        end
        event
      end
    rescue ActiveRecord::RecordNotUnique
      raise EventAlreadyExists, "Event already exists for chain_id: #{chain_id}, block_hash: #{log[:block_hash]}, log_index: #{log[:log_index]}"
    end

    # Mark an event as removed (was reversed)
    # Raises EventNotFound if not found
    def self.mark_removed!(chain_id:, block_hash:, log_index:)
      event = Ethereum::Event.find_by(chain_id: chain_id, block_hash: block_hash, log_index: log_index)
      raise EventNotFound, "Event not found for removal" unless event
      begin
        event.update!(removed: true)
      rescue ActiveRecord::StatementInvalid => e
        if e.cause.is_a?(PG::RaiseException) && e.cause.message.include?("Cannot update a finalized event")
          raise EventFinalized, "Cannot update a finalized event"
        else
          raise
        end
      end
      event
    end

    def self.mark_finalized!(chain_id:, block_hash:, log_index:)
      event = Ethereum::Event.find_by(chain_id: chain_id, block_hash: block_hash, log_index: log_index)
      raise EventNotFound, "Event not found for finalization" unless event
      begin
        event.update!(finalized: true)
      rescue ActiveRecord::StatementInvalid => e
        if e.cause.is_a?(PG::RaiseException) && e.cause.message.include?("Cannot update a finalized event")
          raise EventFinalized, "Cannot update a finalized event"
        else
          raise
        end
      end
      event
    rescue ActiveRecord::RecordNotFound
      raise EventNotFound, "Event not found for finalization"
    end

    # Finalize all unfinalized events older than the given block number for a chain
    # Returns the ids of the events that were just finalized, using a single UPDATE ... RETURNING for concurrency safety
    # @param chain_id [Integer] the chain id
    # @param block_number [Integer] the block number threshold
    # @return [Array<UUID>] ids of events that were finalized
    def self.finalize_older_than(chain_id:, block_number:)
      sql = <<-SQL.squish
        UPDATE ethereum_events
        SET finalized = TRUE
        WHERE chain_id = $1
          AND finalized = FALSE
          AND block_number < $2
        RETURNING id
      SQL
      result = ActiveRecord::Base.connection.raw_connection.exec_params(sql, [ chain_id, block_number ])
      result.values.flatten
    end

    # Find Ethereum::Event records by a set of ids
    # @param ids [Array<String>] the UUID ids to find
    # @return [ActiveRecord::Relation] the matching events
    def self.find_by_ids(ids:)
      return Ethereum::Event.none if ids.blank?
      Ethereum::Event.where(id: ids).order(block_number: :asc, log_index: :asc)
    end
  end
end
