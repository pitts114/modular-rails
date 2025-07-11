# frozen_string_literal: true

require_relative 'decoder_mixin'

module Ethereum
  class EngineTaskSubmittedDecoder
    extend DecoderMixin
    # Decodes a TaskSubmitted event from an Ethereum::Event and its topics
    # Returns a hash with :id, :model, :fee, :sender
    def self.decode(data:, topics:)
      # event TaskSubmitted(bytes32 indexed id, bytes32 indexed model, uint256 fee, address indexed sender)
      # topics[0] is the event signature hash, skip it
      id_hex    = topics[1]
      model_hex = topics[2]
      sender_hex = topics[3]

      fee_hex   = data[0, 66] # Assuming data is a hex string and fee is the first 32 bytes

      {
        id:    id_hex,
        model: model_hex,
        fee:   decode_uint256(fee_hex),
        sender: decode_address(sender_hex)
      }
    end
  end
end
