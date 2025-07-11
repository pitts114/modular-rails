# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_solution_claimed_decoder'

RSpec.describe Ethereum::EngineSolutionClaimedDecoder do
  let(:topics) do
    [
      "0x0b76b4ae356796814d36b46f7c500bbd27b2cce1e6059a6fa2bebfd5a389b190",
      "0x000000000000000000000000d04c1b09576aa4310e4768d8e9cd12fac3216f95",
      "0x48da0289ba6c9e377d9321db9ef25117b11d8fa541a8f2c53b552273a2ce211f"
    ]
  end
  let(:data) { '0x' } # Data is not used in this decoder

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(topics:, data:)
      expect(result[:address]).to eq('0xd04C1B09576AA4310e4768d8E9CD12faC3216f95')
      expect(result[:task]).to eq('0x48da0289ba6c9e377d9321db9ef25117b11d8fa541a8f2c53b552273a2ce211f')
    end
  end
end
