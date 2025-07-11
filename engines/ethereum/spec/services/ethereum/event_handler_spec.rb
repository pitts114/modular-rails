require 'rails_helper'

RSpec.describe Ethereum::EventHandler do
  let(:log) { double(:log_dto, removed: false) }
  let(:chain_id) { 1 }
  let(:raw_event) { { 'blockHash' => '0xblock' } }
  let(:logger) { double('Logger', info: nil, error: nil) }

  let(:mark_event_removed_service) { double('MarkEventRemovedService', call: nil) }
  let(:save_event_service) { double('SaveEventService', call: nil) }
  let(:handler) do
    described_class.new(
      logger: logger,
      mark_event_removed_service: mark_event_removed_service,
      save_event_service: save_event_service
    )
  end

  it 'calls SaveEventService for a new event' do
    expect(save_event_service).to receive(:call).with(log: log, chain_id: chain_id, raw_event: raw_event)
    handler.call(log: log, chain_id: chain_id, raw_event: raw_event)
  end

  it 'calls MarkEventRemovedService if removed is true' do
    allow(log).to receive(:removed).and_return(true)
    expect(mark_event_removed_service).to receive(:call).with(log: log, chain_id: chain_id, raw_event: raw_event)
    handler.call(log: log, chain_id: chain_id, raw_event: raw_event)
  end
end
