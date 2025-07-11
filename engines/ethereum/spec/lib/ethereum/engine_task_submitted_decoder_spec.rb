# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_task_submitted_decoder'

RSpec.describe Ethereum::EngineTaskSubmittedDecoder do
  let(:topics) do
    [
      "0xc3d3e0544c80e3bb83f62659259ae1574f72a91515ab3cae3dd75cf77e1b0aea",
      "0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0",
      "0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a",
      "0x000000000000000000000000b532a213b0d1fbc21d49ea44973e13351bd1609e"
    ]
  end
  let(:data) { '0x00000000000000000000000000000000000000000000000000038d7ea4c68000' }

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(data:, topics:)
      expect(result[:id]).to eq('0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0')
      expect(result[:model]).to eq('0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a')
      expect(result[:fee]).to eq(1_000_000_000_000_000)
      expect(result[:sender]).to eq('0xb532a213B0d1fBC21D49EA44973E13351Bd1609e')
    end
  end
end
