require 'rails_helper'

RSpec.describe Ethereum::SaveEventService do
  let(:repository) { double(:repository, save_event!: nil) }
  let(:logger) { double(:logger) }
  let(:service) { described_class.new(repository: repository, logger: logger) }
  let(:raw_event) do
    {
      'address' => '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      'blockHash' => '0xblock',
      'blockNumber' => '0x10',
      'transactionHash' => '0xtx',
      'transactionIndex' => '0x2',
      'logIndex' => '0x3',
      'removed' => false,
      'data' => '0xdata',
      'topics' => [ '0xtopic1', '0xtopic2' ]
    }
  end
  let(:log) { Ethereum::LogEventDto.new(raw_event) }
  let(:chain_id) { 1 }

  it 'converts hex values and calls save_event! with correct arguments' do
    expect(repository).to receive(:save_event!).with(hash_including(
      log: hash_including(
        address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
        block_hash: '0xblock',
        block_number: 16,
        transaction_hash: '0xtx',
        transaction_index: 2,
        log_index: 3,
        removed: false,
        data: '0xdata',
        topics: [ '0xtopic1', '0xtopic2' ],
        chain_id: chain_id,
        raw_event: log
      ),
      chain_id: chain_id,
      raw_event: log
    ))
    service.call(log:, chain_id:, raw_event:)
  end

  it 'logs an error if save_event! raises EventAlreadyExists' do
    allow(repository).to receive(:save_event!).and_raise(Ethereum::EventRepository::EventAlreadyExists.new('Event already exists'))
    expect(logger).to receive(:error).with(/Event already exists/)
    service.call(log:, chain_id:, raw_event:)
  end
end
