require 'json'
require 'digest/keccak'

module Arbius
  class SerializeService
    def initialize(json_module: JSON)
      @json_module = json_module
    end

    # Serializes a hash to a hex-encoded JSON string (0x-prefixed, reversible)
    def serialize_hash_to_hex(hash:)
      json_string = @json_module.generate(hash)
      '0x' + json_string.unpack1('H*')
    end

    # Deserializes an arbitrary-length hex string (0x-prefixed) to a hash
    # Useful for ABI-encoded bytes input (not bytes32)
    def deserialize_hex_to_hash(hex:)
      raise ArgumentError, 'Invalid hex format' unless hex.start_with?('0x') && hex.length > 2

      # Remove '0x' prefix and any trailing zeros (from padding)
      hex_string = hex[2..-1].sub(/(00)+\z/, '')
      binary_string = [ hex_string ].pack('H*')
      @json_module.parse(binary_string)
    rescue JSON::ParserError => e
      raise ArgumentError, "Failed to deserialize hex: #{e.message}"
    end
  end
end
