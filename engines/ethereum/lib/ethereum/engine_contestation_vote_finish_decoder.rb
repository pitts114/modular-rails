# frozen_string_literal: true

require_relative 'decoder_mixin'

module Ethereum
  class EngineContestationVoteFinishDecoder
    extend DecoderMixin
    def self.decode(data:, topics:)
      id_hex = topics[1]
      start_idx_hex = topics[2]

      end_idx_hex = data[0, 66] # Assuming end_idx is the first 32 bytes in data

      {
        id: id_hex,
        start_idx: start_idx_hex.to_i(16),
        end_idx: end_idx_hex.to_i(16)
      }
    end
  end
end
