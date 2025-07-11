# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_solution_submitted_decoder'

RSpec.describe Ethereum::EngineSolutionSubmittedDecoder do
  let(:topics) do
    [
      "0x957c18b5af8413899ea8a576a4d3fb16839a02c9fccfdce098b6d59ef248525b",
      "0x000000000000000000000000b532a213b0d1fbc21d49ea44973e13351bd1609e",
      "0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0"
    ]
  end
  let(:data) { '0x' } # Data is not used in this decoder

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(topics:, data:)
      expect(result[:address]).to eq('0xb532a213B0d1fBC21D49EA44973E13351Bd1609e')
      expect(result[:task]).to eq('0x00341772a3e4b6d1123fe810284c843efd327ad1f499e5c3a87fbde63c5065b0')
    end
  end
end
