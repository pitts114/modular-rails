# frozen_string_literal: true

require 'rails_helper'

describe Arbius::BulkBogusAutoMineService do
  let(:bulk_submit_task_service) { double(:bulk_submit_task_service) }
  let(:get_task_ids_service) { double(:get_task_ids_service) }
  let(:bulk_bogus_mine_service) { double(:bulk_bogus_mine_service) }
  let(:transaction_status_service) { double(:transaction_status_service) }
  let(:arbius_task_submitted_event_model) { double(:arbius_task_submitted_event_model) }
  let(:wait_for_transaction_service) { double(:wait_for_transaction_service) }
  let(:poller) { double(:poller) }
  let(:time) { double(:time) }
  let(:kernel) { double(:kernel) }
  let(:flipper) { double(:flipper) }
  let(:service) do
    described_class.new(
      bulk_submit_task_service: bulk_submit_task_service,
      get_task_ids_service: get_task_ids_service,
      bulk_bogus_mine_service: bulk_bogus_mine_service,
      transaction_status_service: transaction_status_service,
      arbius_task_submitted_event_model: arbius_task_submitted_event_model,
      wait_for_transaction_service: wait_for_transaction_service,
      poller: poller,
      time: time,
      kernel: kernel,
      flipper: flipper
    )
  end

  let(:from) { '0xabc' }
  let(:model) { '0xmodel' }
  let(:fee) { 123 }
  let(:input) { { foo: 'bar' } }
  let(:version) { 0 }
  let(:owner) { nil }
  let(:n) { 2 }
  let(:ethereum_transaction_id) { '0xeth_tx_id' }
  let(:tx_hash) { '0xtxhash' }
  let(:now) { 1000.0 }
  let(:task_submitted_event1) { double(:task_submitted_event, task_id: 'task1') }
  let(:task_submitted_event2) { double(:task_submitted_event, task_id: 'task2') }
  let(:task_submitted_events) { [ task_submitted_event1, task_submitted_event2 ] }

  before do
    allow(flipper).to receive(:enabled?).with(:bulk_bogus_auto_mine).and_return(true)
    allow(bulk_submit_task_service).to receive(:submit_task).and_return(ethereum_transaction_id)
    allow(wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return(tx_hash)
    allow(time).to receive(:now).and_return(now, now, now + 0.01, now + 0.02, now + described_class::WAIT_FOR_BULK_SUBMITTED_TASKS_TIMEOUT + 0.1)
    allow(arbius_task_submitted_event_model).to receive(:joins).and_return(arbius_task_submitted_event_model)
    allow(arbius_task_submitted_event_model).to receive(:where).and_return(task_submitted_events)
    allow(bulk_bogus_mine_service).to receive(:call)
    allow(kernel).to receive(:sleep).with(described_class::INTERVAL)
  end

  it 'submits tasks, waits for events, bogus mines, and returns task ids' do
    result = service.call(from: from, model: model, fee: fee, input: input, version: version, owner: owner, n: n)
    expect(bulk_submit_task_service).to have_received(:submit_task).with(from: from, version: version, owner: from, model: model, fee: fee, input: input, n: n)
    expect(wait_for_transaction_service).to have_received(:call).with(ethereum_transaction_id: ethereum_transaction_id)
    expect(arbius_task_submitted_event_model).to have_received(:joins).with(:arbius_ethereum_event_details)
    expect(arbius_task_submitted_event_model).to have_received(:where).with(arbius_ethereum_event_details: { transaction_hash: tx_hash })
    expect(bulk_bogus_mine_service).to have_received(:call).with(from: from, taskids: [ 'task1', 'task2' ])
    expect(result).to eq([ 'task1', 'task2' ])
  end

  it 'returns [] if feature flag is disabled' do
    allow(flipper).to receive(:enabled?).with(:bulk_bogus_auto_mine).and_return(false)
    expect(bulk_submit_task_service).not_to receive(:submit_task)
    expect(wait_for_transaction_service).not_to receive(:call)
    expect(bulk_bogus_mine_service).not_to receive(:call)
    expect(transaction_status_service).not_to receive(:call)
    result = service.call(from: from, model: model, fee: fee, input: input, version: version, owner: owner, n: n)
    expect(result).to eq([])
  end

  it 'raises TimeoutError if no events found' do
    allow(arbius_task_submitted_event_model).to receive(:where).and_return([])
    expect {
      service.call(from: from, model: model, fee: fee, input: input, version: version, owner: owner, n: n)
    }.to raise_error(described_class::TimeoutError)
  end
end
