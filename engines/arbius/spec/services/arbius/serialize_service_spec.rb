require 'rails_helper'

RSpec.describe Arbius::SerializeService do
  let(:service) { described_class.new }

  describe '#serialize_hash_to_hex and #deserialize_hex_to_hash' do
    it 'serializes and deserializes a hash correctly' do
      hash = { 'foo' => 'bar', 'baz' => 123 }
      hex = service.serialize_hash_to_hex(hash: hash)
      expect(hex).to start_with('0x')
      result = service.deserialize_hex_to_hash(hex: hex)
      expect(result).to eq(hash)
    end

    it 'raises error for invalid hex input' do
      expect {
        service.deserialize_hex_to_hash(hex: 'not_a_hex')
      }.to raise_error(ArgumentError)
    end

    it 'raises error for non-JSON hex input' do
      # 0x313233 is hex for '123', which is valid JSON (number), so use invalid JSON
      bad_hex = '0x7b22666f6f223a7d' # '{"foo":}'
      expect {
        service.deserialize_hex_to_hash(hex: bad_hex)
      }.to raise_error(ArgumentError)
    end
  end
end
