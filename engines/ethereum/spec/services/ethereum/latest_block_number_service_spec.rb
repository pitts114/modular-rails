require 'rails_helper'

RSpec.describe Ethereum::LatestBlockNumberService do
  let(:eth_client) { double(:eth_client, eth_get_block_by_number: { "result" => { 'number' => '0x1' } }) }
  let(:service) { described_class.new(eth_client:) }

  describe '#call' do
    it 'returns the latest block number as an integer' do
      expect(service.call).to eq(1)
    end
  end
end
