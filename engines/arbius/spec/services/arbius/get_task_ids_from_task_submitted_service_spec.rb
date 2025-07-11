# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::GetTaskIdsFromTaskSubmittedService, type: :service do
  let(:receipt_service) { double(:receipt_service) }
  let(:service) { described_class.new(receipt_service: receipt_service) }
  let(:tx_hash) { '0xb6c0b7656842292129143287a586d059de2c77f56ecdf99835f072c74e9a0d4e' }
  let(:event_sig) { Arbius::GetTaskIdsFromTaskSubmittedService::TASK_SUBMITTED_EVENT_SIG }

  def load_fixture(name)
    path = Rails.root.join('engines', 'arbius', 'spec', 'fixtures', "#{name}.json")
    JSON.parse(File.read(path))
  end

  context 'when TaskSubmitted events are present' do
    let(:receipt) { load_fixture('submit_task_transaction_receipt') }
    before do
      allow(receipt_service).to receive(:fetch).with(tx_hash: tx_hash).and_return(receipt)
    end

    it 'returns all task ids from TaskSubmitted events' do
      # There is one TaskSubmitted event in the fixture, topic[1] is the task id
      expected_task_ids = receipt['logs'].select { |log| log['topics']&.first == event_sig }.map { |log| log['topics'][1] }
      expect(service.call(tx_hash: tx_hash)).to eq(expected_task_ids)
    end
  end

  context 'when no TaskSubmitted events are present' do
    let(:receipt) { { 'logs' => [] } }
    before do
      allow(receipt_service).to receive(:fetch).with(tx_hash: tx_hash).and_return(receipt)
    end

    it 'raises an error' do
      expect { service.call(tx_hash: tx_hash) }.to raise_error('No TaskSubmitted events found in transaction')
    end
  end

  context 'when receipt is nil' do
    before do
      allow(receipt_service).to receive(:fetch).with(tx_hash: tx_hash).and_return(nil)
    end

    it 'raises an error' do
      expect { service.call(tx_hash: tx_hash) }.to raise_error('No logs found in transaction receipt')
    end
  end
end
