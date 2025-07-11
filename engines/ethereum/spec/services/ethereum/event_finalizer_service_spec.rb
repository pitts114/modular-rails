require 'rails_helper'

RSpec.describe Ethereum::EventFinalizerService do
  let(:chain_id) { 1 }
  let(:client) { double(:client, chain_id:) }
  let(:event_repository) { double(:event_repository) }
  let(:latest_block_number_service) { double(:latest_block_number_service) }
  let(:publish_event_job) { double(:publish_event_job) }
  let(:service) do
    described_class.new(
      client:,
      event_repository:,
      latest_block_number_service:,
      publish_event_job:
    )
  end

  let(:block_number) { 12345 }
  let(:finalized_ids) { [ 1, 2 ] }

  before do
    allow(latest_block_number_service).to receive(:call).and_return(block_number)
    allow(event_repository).to receive(:finalize_older_than).with(chain_id: chain_id, block_number: block_number + 1).and_return(finalized_ids)
    allow(publish_event_job).to receive(:perform_later)
  end

  describe '#call' do
    it 'calls finalize_older_than on the repository with the latest finalized block number' do
      expect(event_repository).to receive(:finalize_older_than).with(chain_id: chain_id, block_number: block_number + 1)
      service.call
    end

    it 'enqueues PublishEventJob for all finalized event ids' do
      finalized_ids.each do |id|
        expect(publish_event_job).to receive(:perform_later).with(id)
      end
      service.call
    end
  end
end
