# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/ethereum/engine_contestation_vote_finish_decoder'

RSpec.describe Ethereum::EngineContestationVoteFinishDecoder do
  let(:topics) do
    [
      "0x71d8c71303e35a39162e33a402c9897bf9848388537bac7d5e1b0d202eca4e66",
      "0x5006e359c742def98606028fcb37025808fb3496343cee65907d86fff09c7e8c",
      "0x0000000000000000000000000000000000000000000000000000000000000000"
    ]
  end
  let(:data) { '0x0000000000000000000000000000000000000000000000000000000000000003' }

  describe '.decode' do
    it 'returns a hash with id, start_idx, and end_idx' do
      result = described_class.decode(topics: topics, data: data)
      expect(result[:id]).to eq('0x5006e359c742def98606028fcb37025808fb3496343cee65907d86fff09c7e8c')
      expect(result[:start_idx]).to eq(0)
      expect(result[:end_idx]).to eq(3)
    end
  end
end
