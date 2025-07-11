require_relative '../../../../../lib/eth_event_utils'

module Ethereum
  class EventDecoderService
    class UnknownEventError < StandardError; end

    def initialize(
      eth_event_utils: EthEventUtils,
      event_decoder_registry_entries: Ethereum::EventDecoderRegistry::ENTRIES
    )
      @eth_event_utils = eth_event_utils
      @event_decoder_registry_entries = event_decoder_registry_entries
      @decoder_registry = {}
      @contract_registry = {}
      @event_decoder_registry_entries.each do |entry|
        register_decoder(address: entry[:address], event_name: entry[:event_name], decoder: entry[:decoder], contract: entry[:contract])
      end
    end

    def call(ethereum_event:)
      address = ethereum_event.address
      topic0 = topic0(ethereum_event:)
      topics = topics(ethereum_event:)
      data = ethereum_event.data

      event_name = event_name_from_topic0(address: address, topic0: topic0)
      decoder = @decoder_registry[[ address.downcase, event_name ]]
      if decoder.nil?
        raise UnknownEventError, "Unknown event with topic0: #{topic0} for contract: #{address} for ethereum_event: #{ethereum_event.id}"
      end
      event_data = decoder.decode(data: data, topics: topics)

      {
        address:,
        event_name:,
        chain_id: ethereum_event.chain_id,
        event_data: event_data
      }
    end

    private

    def register_decoder(address:, event_name:, decoder:, contract:)
      @decoder_registry[[ address.downcase, event_name ]] = decoder
      register_contract(address:, contract:) if contract
    end

    def register_contract(address:, contract:)
      @contract_registry[address.downcase] = contract
    end

    def event_name_from_topic0(address:, topic0:)
      contract = @contract_registry[address.downcase]
      return nil unless contract
      @decoder_registry.keys.select { |(addr, _)| addr == address.downcase }.each do |(_, event_name)|
        return event_name if to_topic0(event_name:, contract:) == topic0
      end
      nil
    end

    def to_topic0(event_name:, contract:)
      @eth_event_utils.topic0_for(event_name:, abi: contract.abi)
    end

    def topics(ethereum_event:)
      ethereum_event.ethereum_event_topics.order(topic_index: :asc).pluck(:topic)
    end

    def topic0(ethereum_event:)
      ethereum_event.ethereum_event_topics.find_by(topic_index: 0).topic
    end
  end
end
