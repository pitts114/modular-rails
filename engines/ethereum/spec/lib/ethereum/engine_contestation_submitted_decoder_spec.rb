# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_contestation_submitted_decoder'

RSpec.describe Ethereum::EngineContestationSubmittedDecoder do
  let(:topics) do
    [
      "0x6958c989e915d3e41a35076e3c480363910055408055ad86ae1ee13d41c40640",
      "0x0000000000000000000000000f1756227ef240372d77ec66c8ffa2e68c09dc69",
      "0x95e894c7ebeea9786c690849a1757bdb358e7a2a5eafb3e1616bf3033fefd79c"
    ]
  end
  let(:data) { '0x' } # Data is not used in this decoder

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(topics:, data:)
      expect(result[:address]).to eq('0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69')
      expect(result[:task]).to eq('0x95e894c7ebeea9786c690849a1757bdb358e7a2a5eafb3e1616bf3033fefd79c')
    end
  end
end
