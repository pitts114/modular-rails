require 'rails_helper'
require 'json'
require_relative '../../../app/dto/ethereum/log_event_dto'

RSpec.describe Ethereum::LogEventDto do
  let(:json_log) do
    '{
      "logIndex": "0x0",
      "removed": false,
      "blockNumber": "0x233",
      "blockHash": "0xfc139f5e2edee9e9c888d8df9a2d2226133a9bd87c88ccbd9c930d3d4c9f9ef5",
      "transactionHash": "0x66e7a140c8fa27fe98fde923defea7562c3ca2d6bb89798aabec65782c08f63d",
      "transactionIndex": "0x0",
      "address": "0x42699a7612a82f1d9c36148af9c77354759b210b",
      "data": "0x0000000000000000000000000000000000000000000000000000000000000004",
      "topics": [
        "0x04474795f5b996ff80cb47c148d4c5ccdbe09ef27551820caa9c2f8ed149cce3"
      ]
    }'
  end

  it 'normalizes keys and allows attribute access' do
    dto = described_class.new(json_log)
    expect(dto.log_index).to eq('0x0')
    expect(dto.removed).to eq(false)
    expect(dto.block_number).to eq('0x233')
    expect(dto.block_hash).to eq('0xfc139f5e2edee9e9c888d8df9a2d2226133a9bd87c88ccbd9c930d3d4c9f9ef5')
    expect(dto.transaction_hash).to eq('0x66e7a140c8fa27fe98fde923defea7562c3ca2d6bb89798aabec65782c08f63d')
    expect(dto.transaction_index).to eq('0x0')
    expect(dto.address).to eq('0x42699a7612a82f1d9c36148af9c77354759b210b')
    expect(dto.data).to eq('0x0000000000000000000000000000000000000000000000000000000000000004')
    expect(dto.topics).to eq([ "0x04474795f5b996ff80cb47c148d4c5ccdbe09ef27551820caa9c2f8ed149cce3" ])
  end
end
