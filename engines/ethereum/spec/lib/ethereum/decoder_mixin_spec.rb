# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/decoder_mixin'

RSpec.describe Ethereum::DecoderMixin do
  class DummyDecoder
    extend Ethereum::DecoderMixin
  end

  describe 'decode_uint256' do
    it 'decodes a hex string to uint256 integer' do
      hex = '0x0000000000000000000000000000000000000000000000000000000000000037'
      expect(DummyDecoder.decode_uint256(hex)).to eq(55)
    end
  end

  describe 'decode_address' do
    it 'decodes a hex string to an Ethereum address' do
      hex = '0x0000000000000000000000000f1756227ef240372d77ec66c8ffa2e68c09dc69'
      expect(DummyDecoder.decode_address(hex)).to eq('0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69')
    end
  end

  describe 'decode_bool' do
    it 'decodes a hex string to a boolean' do
      hex_true = '0x0000000000000000000000000000000000000000000000000000000000000001'
      hex_false = '0x0000000000000000000000000000000000000000000000000000000000000000'
      expect(DummyDecoder.decode_bool(hex_true)).to be true
      expect(DummyDecoder.decode_bool(hex_false)).to be false
    end

    it 'raises an error for invalid boolean values' do
      expect { DummyDecoder.decode_bool('0x02') }.to raise_error(ArgumentError, 'Invalid boolean value')
    end
  end
end
