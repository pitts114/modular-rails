# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_validator_deposit_decoder'

RSpec.describe Ethereum::EngineValidatorDepositDecoder do
  let(:topics) do
    [
      "0x8d4844488c19a90828439e71d14ebad860806d04f8ef8b25a82179fab2699b89",
      "0x000000000000000000000000b532a213b0d1fbc21d49ea44973e13351bd1609e",
      "0x00000000000000000000000095f8b7dd37c4851596f08f297b3bdb7025f8a09e"
    ]
  end
  let(:data) { '0x0000000000000000000000000000000000000000000000001bc16d674ec80000' }

  describe '.decode' do
    it 'returns a hash with address, validator, and amount' do
      result = described_class.decode(data:, topics:)
      expect(result[:address]).to eq('0xb532a213B0d1fBC21D49EA44973E13351Bd1609e')
      expect(result[:validator]).to eq('0x95f8b7dd37c4851596f08f297B3bDb7025f8a09e')
      expect(result[:amount]).to eq(2_000_000_000_000_000_000)
    end
  end
end
