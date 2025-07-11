# frozen_string_literal: true

require_relative 'decoder_mixin'

module Ethereum
  class EngineContestationVoteDecoder
    extend DecoderMixin
    def self.decode(data:, topics:)
      address_hex    = topics[1]
      task_hex = topics[2]

      yea_hex = data[0, 66] # Assuming yea is the first 32 bytes in data

      {
        address: decode_address(address_hex),
        task:    task_hex,
        yea:    decode_bool(yea_hex)
      }
    end
  end
end
