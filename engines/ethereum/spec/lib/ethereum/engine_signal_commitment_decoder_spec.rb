# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_solution_submitted_decoder'

RSpec.describe Ethereum::EngineSolutionSubmittedDecoder do
  let(:topics) do
    [
      "0x09b4c028a2e50fec6f1c6a0163c59e8fbe92b231e5c03ef3adec585e63a14b92",
      "0x000000000000000000000000b532a213b0d1fbc21d49ea44973e13351bd1609e",
      "0x9823ad46863de7a263a7674c38002b36998a435ceac3e3507cb9ae325db94a74"
    ]
  end
  let(:data) { '0x' } # Data is not used in this decoder

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(topics:, data:)
      expect(result[:address]).to eq('0xb532a213B0d1fBC21D49EA44973E13351Bd1609e')
      expect(result[:task]).to eq('0x9823ad46863de7a263a7674c38002b36998a435ceac3e3507cb9ae325db94a74')
    end
  end
end
