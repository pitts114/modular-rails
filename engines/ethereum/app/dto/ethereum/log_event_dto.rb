require 'json'
require 'active_support/core_ext/hash/keys'
require 'active_support/inflector'

module Ethereum
  class LogEventDto
    ATTRS = [
      :address, :block_hash, :block_number, :transaction_hash, :transaction_index,
      :log_index, :removed, :data, :topics
    ]

    attr_reader(*ATTRS)

    def initialize(input)
      hash = parse_input(input)
      normalized = normalize_keys(hash)
      ATTRS.each do |attr|
        instance_variable_set("@#{attr}", normalized[attr])
      end
      @raw_event = hash
    end

    def self.from_json(json)
      new(JSON.parse(json))
    end

    private

    # Accepts string, symbol, camelCase, or snake_case keys
    def normalize_keys(hash)
      hash.deep_transform_keys do |k|
        k = k.to_s
        k = k.underscore
        k.to_sym
      end
    end

    def parse_input(input)
      case input
      when String
        JSON.parse(input)
      when Hash
        input
      else
        raise ArgumentError, "Unsupported input type: #{input.class}"
      end
    end
  end
end
