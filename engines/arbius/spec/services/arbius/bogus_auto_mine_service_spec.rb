# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BogusAutoMineService do
  let(:mock_submit_task_service) { double(:submit_task_service) }
  let(:mock_wait_for_transaction_service) { double(:wait_for_transaction_service) }
  let(:mock_bogus_mine_service) { double(:bogus_mine_service) }
  let(:mock_poller) { double(:poller) }
  let(:service) do
    described_class.new(
      submit_task_service: mock_submit_task_service,
      bogus_mine_service: mock_bogus_mine_service,
      arbius_task_submitted_event_model: double(:arbius_task_submitted_event_model), # not used directly
      wait_for_transaction_service: mock_wait_for_transaction_service,
      poller: mock_poller
    )
  end

  it 'submits a task, waits for confirmation, polls for the event, and bogus mines a solution' do
    from = '0xabc'
    model = '0x123'
    fee = 1000
    input = { foo: 'bar' }
    ethereum_transaction_id = '0xdeadbeef'
    tx_hash = '0xconfirmed'
    task_id = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    event = double('event', task_id: task_id)

    expect(mock_submit_task_service).to receive(:submit_task).with(from: from, version: 0, owner: from, model: model, fee: fee, input: input).and_return(ethereum_transaction_id)
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return(tx_hash)
    expect(mock_poller).to receive(:poll).and_return(event)
    expect(mock_bogus_mine_service).to receive(:call).with(from: from, taskid: task_id)

    expect(service.call(from: from, model: model, fee: fee, input: input)).to eq(task_id)
  end

  it 'raises if poller raises TimeoutError (event not found)' do
    ethereum_transaction_id = '0xdeadbeef'
    tx_hash = '0xconfirmed'
    expect(mock_submit_task_service).to receive(:submit_task).and_return(ethereum_transaction_id)
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return(tx_hash)
    expect(mock_poller).to receive(:poll).and_raise(Arbius::Polling::Poller::TimeoutError)
    expect {
      service.call(from: '0xabc', model: '0x123', fee: 1, input: {})
    }.to raise_error('TaskSubmittedEvent not found in time')
  end

  it 'uses the provided owner value if not nil' do
    from = '0xabc'
    owner = '0xdef'
    model = '0x123'
    fee = 1000
    input = { foo: 'bar' }
    ethereum_transaction_id = '0xdeadbeef'
    tx_hash = '0xconfirmed'
    task_id = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    event = double('event', task_id: task_id)

    expect(mock_submit_task_service).to receive(:submit_task).with(from: from, version: 0, owner: owner, model: model, fee: fee, input: input).and_return(ethereum_transaction_id)
    expect(mock_wait_for_transaction_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return(tx_hash)
    expect(mock_poller).to receive(:poll).and_return(event)
    expect(mock_bogus_mine_service).to receive(:call).with(from: from, taskid: task_id)

    service.call(from: from, model: model, fee: fee, input: input, owner: owner)
  end
end
