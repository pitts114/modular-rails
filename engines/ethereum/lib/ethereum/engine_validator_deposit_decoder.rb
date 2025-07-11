# frozen_string_literal: true

require_relative 'decoder_mixin'

module Ethereum
  class EngineValidatorDepositDecoder
    extend DecoderMixin
    def self.decode(data:, topics:)
      address = topics[1]
      validator = topics[2]

      amount = data[0, 66] # Assuming amount is the first 32 bytes in data

      {
        address: decode_address(address),
        validator: decode_address(validator),
        amount: amount.to_i(16)
      }
    end
  end
end
