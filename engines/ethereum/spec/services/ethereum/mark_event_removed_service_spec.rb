require 'rails_helper'

RSpec.describe Ethereum::MarkEventRemovedService do
  let(:repository) { double(:repository, mark_removed!: nil, save_event!: nil) }
  let(:logger) { double(:logger, error: nil) }
  let(:save_event_service) { double(:save_event_service, call: nil) }
  let(:service) { described_class.new(repository: repository, logger: logger, save_event_service: save_event_service) }
  let(:log) { double(:log_dto, block_hash: '0xblock', log_index: 0x1, removed: true) }
  let(:raw_event) do
    {
      'blockHash' => '0xblock',
      'logIndex' => '0x1',
      'removed' => true
    }
  end
  let(:chain_id) { 1 }

  it 'calls mark_removed! with converted values' do
    expect(repository).to receive(:mark_removed!).with(chain_id: chain_id, block_hash: '0xblock', log_index: 1)
    service.call(log: log, chain_id: chain_id, raw_event: raw_event)
  end

  it 'logs and calls SaveEventService if EventNotFound is raised' do
    allow(repository).to receive(:mark_removed!).and_raise(Ethereum::EventRepository::EventNotFound.new('not found'))
    expect(logger).to receive(:error).with(/Tried to remove event but not found/)
    expect(save_event_service).to receive(:call).with(log:, chain_id:, raw_event:)
    service.call(log: log, chain_id: chain_id, raw_event: raw_event)
  end
end
