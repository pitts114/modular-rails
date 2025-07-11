# frozen_string_literal: true

require_relative 'decoder_mixin'

module Ethereum
  class EngineContestationSubmittedDecoder
    extend DecoderMixin
    def self.decode(data:, topics:)
      addr_hex    = topics[1]
      task_hex = topics[2]

      {
        address: decode_address(addr_hex),
        task:    task_hex
      }
    end
  end
end
