# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_contestation_vote_decoder'

RSpec.describe Ethereum::EngineContestationVoteDecoder do
  let(:topics) do
    [
      "0x1aa9e4be46e24e1f2e7eeb1613c01629213cd42965d2716e18531b63e552e411",
      "0x0000000000000000000000000f1756227ef240372d77ec66c8ffa2e68c09dc69",
      "0x95e894c7ebeea9786c690849a1757bdb358e7a2a5eafb3e1616bf3033fefd79c"
    ]
  end
  let(:data) { '0x0000000000000000000000000000000000000000000000000000000000000001' }

  describe '.decode' do
    it 'returns a hash with id, model, fee, and sender' do
      result = described_class.decode(topics:, data:)
      expect(result[:address]).to eq('0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69')
      expect(result[:task]).to eq('0x95e894c7ebeea9786c690849a1757bdb358e7a2a5eafb3e1616bf3033fefd79c')
      expect(result[:yea]).to eq(true)
    end
  end
end
