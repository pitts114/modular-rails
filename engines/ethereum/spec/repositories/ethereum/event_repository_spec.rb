require 'rails_helper'

RSpec.describe Ethereum::EventRepository do
  let(:log) do
    {
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      block_hash: '0xblock',
      block_number: 1,
      transaction_hash: '0xtx',
      transaction_index: 0,
      log_index: 0,
      removed: false,
      data: '0xdata',
      chain_id: 1,
      finalized: false,
      raw_event: { foo: 'bar' },
      topics: [ '0xtopic1', '0xtopic2' ]
    }
  end
  let(:chain_id) { 1 }

  describe '.save_event!' do
    it 'creates an event and its topics' do
      event = described_class.save_event!(log:, chain_id:, raw_event: log)
      expect(event).to be_persisted
      topics = event.ethereum_event_topics.order(:topic_index)
      expect(topics.count).to eq(2)
      expect(topics.first.topic).to eq('0xtopic1')
      expect(topics.first.topic_index).to eq(0)
      expect(topics.second.topic).to eq('0xtopic2')
      expect(topics.second.topic_index).to eq(1)
    end
  end

  describe '.mark_removed!' do
    it 'marks an existing event as removed' do
      event = described_class.save_event!(log:, chain_id:, raw_event: log)
      expect(event.removed).to be false
      described_class.mark_removed!(chain_id: 1, block_hash: '0xblock', log_index: 0)
      expect(event.reload.removed).to be true
    end

    it 'raises if event does not exist' do
      expect {
        described_class.mark_removed!(chain_id: 99, block_hash: 'nope', log_index: 0)
      }.to raise_error(Ethereum::EventRepository::EventNotFound)
    end

    it 'raises EventAlreadyExists if trying to save an existing event' do
      described_class.save_event!(log:, chain_id:, raw_event: log)
      expect {
        described_class.save_event!(log:, chain_id:, raw_event: log)
      }.to raise_error(Ethereum::EventRepository::EventAlreadyExists)
    end

    it 'raises EventFinalized if trying to update a finalized event' do
      event = described_class.save_event!(log:, chain_id:, raw_event: log)
      described_class.mark_finalized!(chain_id: 1, block_hash: '0xblock', log_index: 0)
      expect(event.reload.finalized).to be true
      expect {
        described_class.mark_removed!(chain_id: 1, block_hash: '0xblock', log_index: 0)
      }.to raise_error(Ethereum::EventRepository::EventFinalized)
    end
  end

  describe '.mark_finalized!' do
    it 'marks an existing event as finalized' do
      event = described_class.save_event!(log:, chain_id:, raw_event: log)
      expect(event.finalized).to be false
      described_class.mark_finalized!(chain_id: 1, block_hash: '0xblock', log_index: 0)
      expect(event.reload.finalized).to be true
    end

    it 'raises error if event does not exist' do
      expect {
        described_class.mark_finalized!(chain_id: 99, block_hash: 'nope', log_index: 0)
      }.to raise_error(Ethereum::EventRepository::EventNotFound)
    end
  end

  describe '.unfinalized_older_than' do
    let!(:old_unfinalized) do
      described_class.save_event!(log: log.merge(block_number: 10, finalized: false), chain_id: chain_id, raw_event: log)
    end
    let!(:new_unfinalized) do
      described_class.save_event!(log: log.merge(block_number: 20, finalized: false, log_index: 1), chain_id: chain_id, raw_event: log)
    end
    let!(:old_finalized) do
      described_class.save_event!(log: log.merge(block_number: 10, finalized: true, log_index: 2), chain_id: chain_id, raw_event: log)
    end

    it 'returns only unfinalized events older than the given block number' do
      results = described_class.unfinalized_older_than(chain_id: chain_id, block_number: 15)
      expect(results).to include(old_unfinalized)
      expect(results).not_to include(new_unfinalized)
      expect(results).not_to include(old_finalized)
    end

    it 'returns empty if no events match' do
      results = described_class.unfinalized_older_than(chain_id: chain_id, block_number: 5)
      expect(results).to be_empty
    end
  end

  describe '.finalize_older_than' do
    let!(:old_unfinalized1) do
      described_class.save_event!(log: log.merge(block_number: 10, finalized: false, log_index: 3), chain_id: chain_id, raw_event: log)
    end
    let!(:old_unfinalized2) do
      described_class.save_event!(log: log.merge(block_number: 12, finalized: false, log_index: 4), chain_id: chain_id, raw_event: log)
    end
    let!(:new_unfinalized) do
      described_class.save_event!(log: log.merge(block_number: 20, finalized: false, log_index: 5), chain_id: chain_id, raw_event: log)
    end
    let!(:old_finalized) do
      described_class.save_event!(log: log.merge(block_number: 10, finalized: true, log_index: 6), chain_id: chain_id, raw_event: log)
    end

    it 'finalizes and returns only the ids of unfinalized events older than the given block number' do
      ids = described_class.finalize_older_than(chain_id: chain_id, block_number: 15)
      expect(ids).to match_array([ old_unfinalized1.id, old_unfinalized2.id ])
      expect(old_unfinalized1.reload.finalized).to be true
      expect(old_unfinalized2.reload.finalized).to be true
      expect(new_unfinalized.reload.finalized).to be false
      expect(old_finalized.reload.finalized).to be true
    end

    it 'returns empty array if no events match' do
      ids = described_class.finalize_older_than(chain_id: chain_id, block_number: 5)
      expect(ids).to eq([])
    end

    it 'is concurrency safe: only one process finalizes and gets the ids' do
      # Simulate two processes calling at the same time
      ids1 = described_class.finalize_older_than(chain_id: chain_id, block_number: 15)
      ids2 = described_class.finalize_older_than(chain_id: chain_id, block_number: 15)
      # Only one should get the ids, the other should get []
      expect([ ids1, ids2 ]).to include([ old_unfinalized1.id, old_unfinalized2.id ])
      expect([ ids1, ids2 ]).to include([])
    end
  end

  describe '.find_by_ids' do
    let!(:event1) { described_class.save_event!(log: log.merge(log_index: 11, block_number: 5, block_hash: '0xblock5'), chain_id: chain_id, raw_event: log) }
    let!(:event2) { described_class.save_event!(log: log.merge(log_index: 11, block_number: 4, block_hash: '0xblock4'), chain_id: chain_id, raw_event: log) }
    let!(:event3) { described_class.save_event!(log: log.merge(log_index: 12, block_number: 4, block_hash: '0xblock4'), chain_id: chain_id, raw_event: log) }

    it 'returns the events matching the given ids' do
      results = described_class.find_by_ids(ids: [ event1.id, event3.id ])
      expect(results.map(&:id)).to match_array([ event1.id, event3.id ])
    end

    it 'returns events ordered by block_number and log_index ascending' do
      # event1: log_index 10, event2: 11, event3: 12, all block_number 1
      # Let's shuffle the input order
      results = described_class.find_by_ids(ids: [ event3.id, event1.id, event2.id ])
      expect(results.map(&:id)).to eq([ event2.id, event3.id, event1.id ])
    end

    it 'returns an empty relation if ids is empty' do
      results = described_class.find_by_ids(ids: [])
      expect(results).to be_empty
    end

    it 'returns an empty relation if no ids match' do
      results = described_class.find_by_ids(ids: [ '00000000-0000-0000-0000-000000000000' ])
      expect(results).to be_empty
    end
  end
end
