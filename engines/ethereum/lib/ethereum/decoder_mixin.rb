# frozen_string_literal: true

require 'eth'

module Ethereum
  module DecoderMixin
    def decode_uint256(hex)
      hex.sub(/^0x/, '').to_i(16)
    end

    def decode_address(hex)
      address = '0x' + hex[-40..-1].downcase
      Eth::Address.new(address).checksummed
    end

    def decode_bool(hex)
      value = hex.sub(/^0x/, '').to_i(16)
      case value
      when 0
        false
      when 1
        true
      else
        raise ArgumentError, 'Invalid boolean value'
      end
    end
  end
end
