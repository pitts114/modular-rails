require_relative '../../../../../lib/eth_event_utils'

module Ethereum
  class PublishEventService
    class UnknownEventError < StandardError; end
    class EventNotFoundError < StandardError; end

    def initialize(
      notifications: ActiveSupport::Notifications,
      event_decoder_service: Ethereum::EventDecoderService.new,
      ethereum_event_model: Ethereum::Event
    )
      @notifications = notifications
      @event_decoder_service = event_decoder_service
      @ethereum_event_model = ethereum_event_model
    end

    def call(ethereum_event_id:)
      ethereum_event = @ethereum_event_model.find(ethereum_event_id)
      decoded_event = @event_decoder_service.call(ethereum_event:)
      chain_id = ethereum_event.chain_id
      address = ethereum_event.address
      event_name = decoded_event[:event_name].underscore

      name = name(chain_id:, address:, event_name:)
      event_data = decoded_event[:event_data]
      payload = event_data.merge(
        ethereum_event_id: ethereum_event.id,
        block_hash: ethereum_event.block_hash,
        block_number: ethereum_event.block_number,
        chain_id:,
        contract_address: address,
        transaction_hash: ethereum_event.transaction_hash,
        transaction_index: ethereum_event.transaction_index
      )

      @notifications.instrument(name, payload)
    rescue Ethereum::EventDecoderService::UnknownEventError => e
      raise UnknownEventError, "Failed to decode event for chain #{chain_id}, address #{address}, event_name #{event_name}: #{e.message}"
    rescue ActiveRecord::RecordNotFound
      raise EventNotFoundError, "Ethereum event with ID #{ethereum_event_id} not found"
    end

    private

    def name(chain_id:, address:, event_name:)
      "ethereum.#{chain_id}_#{address}_#{event_name}"
    end
  end
end
