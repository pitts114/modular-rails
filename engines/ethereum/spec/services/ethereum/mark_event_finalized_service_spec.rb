require 'rails_helper'

RSpec.describe Ethereum::MarkEventFinalizedService do
  let(:repository) { double(:repository, mark_removed!: nil, save_event!: nil) }
  let(:service) { described_class.new(repository: repository) }
  let(:ethereum_event) { double(:ethereum_event, chain_id: 1, block_hash: '0xblock', log_index: 1) }

  it 'calls mark_finalized! with attribute values' do
    expect(repository).to receive(:mark_finalized!).with(chain_id: ethereum_event.chain_id, block_hash: ethereum_event.block_hash, log_index: ethereum_event.log_index)
    service.call(ethereum_event: ethereum_event)
  end
end
