require 'spec_helper'
require_relative "../../../lib/ethereum/event_poller"

RSpec.describe Ethereum::EventPoller do
  let(:mock_client) { double('Eth::Client') }
  let(:contract) { double('Eth::Contract', address: '0xabc') }
  let(:topic0) { '0xtopic0' }
  let(:event_name_to_topic0) { { contract => { 'TestEvent' => topic0 } } }
  let(:log1) { { 'blockNumber' => '0x1', 'data' => 'foo', 'topics' => [ topic0 ] } }
  let(:log2) { { 'blockNumber' => '0x2', 'data' => 'bar', 'topics' => [ topic0 ] } }
  let(:logger) { double(:logger, info: nil, debug: nil) }

  before do
    allow(mock_client).to receive(:eth_block_number).and_return({ 'result' => '0x2' })
    allow(mock_client).to receive(:eth_get_logs).and_return({ 'result' => [ log1, log2 ] })
  end

  it 'yields logs and last_processed_block for each poll' do
    poller = described_class.new(
      client: mock_client,
      contracts: [ contract ],
      event_name_to_topic0: event_name_to_topic0,
      start_block: 1,
      batch_size: 2,
      poll_interval: 0,
      logger: logger
    )
    yielded = []
    poller.poll_once { |type, value| yielded << [ type, value ] }
    expect(yielded).to eq([
      [ :log, log1 ],
      [ :log, log2 ],
      [ :last_processed_block, 2 ]
    ])
    expect(poller.last_processed_block).to eq(3)
  end

  it 'does not yield if from_block > to_block' do
    poller = described_class.new(
      client: mock_client,
      contracts: [ contract ],
      event_name_to_topic0: event_name_to_topic0,
      start_block: 3,
      batch_size: 2,
      poll_interval: 0,
      logger: logger
    )
    expect { |b| poller.poll_once(&b) }.not_to yield_control
  end

  it 'sets @running to false when stop is called' do
    poller = described_class.new(
      client: mock_client,
      contracts: [ contract ],
      event_name_to_topic0: event_name_to_topic0,
      start_block: 1,
      batch_size: 2,
      poll_interval: 0,
      logger: logger
    )
    poller.stop
    expect(poller.instance_variable_get(:@running)).to eq(false)
  end

  it 'run exits when stop is called' do
    poller = described_class.new(
      client: mock_client,
      contracts: [ contract ],
      event_name_to_topic0: event_name_to_topic0,
      start_block: 1,
      batch_size: 2,
      poll_interval: 0.01,
      logger: logger
    )
    allow(poller).to receive(:poll_once) { sleep(0.01) }
    thread = Thread.new { poller.run }
    sleep(0.03)
    poller.stop
    thread.join(1)
    expect(thread).not_to be_alive
  end
end
