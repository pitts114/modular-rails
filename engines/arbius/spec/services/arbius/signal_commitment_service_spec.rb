# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::SignalCommitmentService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract) }

  it 'calls EngineContract#signal_commitment with correct arguments and context' do
    from = '0xabc'
    commitment = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    ethereum_event_id = '42'
    expected_context = { class: 'Arbius::SignalCommitmentService', from: from }
    expect(mock_engine_contract).to receive(:signal_commitment).with(from: from, commitment: commitment, context: expected_context).and_return(ethereum_event_id)
    expect(service.call(from: from, commitment: commitment)).to eq(ethereum_event_id)
  end
end
