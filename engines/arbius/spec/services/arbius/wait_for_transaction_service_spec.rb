require 'rails_helper'

RSpec.describe Arbius::WaitForTransactionService do
  let(:transaction_status_service) { double(:transaction_status_service) }
  let(:time) { double(:time) }
  let(:service) { described_class.new(transaction_status_service: transaction_status_service, time: time) }
  let(:ethereum_transaction_id) { '0xabc' }

  it 'returns tx_hash when transaction is confirmed immediately' do
    expect(time).to receive(:now).and_return(0)
    expect(transaction_status_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return({ status: 'confirmed', tx_hash: '0x123' })
    expect(service.call(ethereum_transaction_id: ethereum_transaction_id, timeout: 5, interval: 0)).to eq('0x123')
  end

  it 'waits and returns tx_hash when transaction is confirmed after retries' do
    expect(time).to receive(:now).and_return(0, 1, 2)
    expect(transaction_status_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).exactly(3).times.and_return(
      { status: 'pending' },
      { status: 'pending' },
      { status: 'confirmed', tx_hash: '0x456' }
    )
    expect(service.call(ethereum_transaction_id: ethereum_transaction_id, timeout: 5, interval: 0)).to eq('0x456')
  end

  it 'raises if transaction is not confirmed in time' do
    # Simulate time passing to exceed timeout
    expect(time).to receive(:now).and_return(0, 1, 2, 3, 4, 5)
    allow(transaction_status_service).to receive(:call).with(ethereum_transaction_id: ethereum_transaction_id).and_return({ status: 'pending' })
    expect {
      service.call(ethereum_transaction_id: ethereum_transaction_id, timeout: 5, interval: 0)
    }.to raise_error(Arbius::WaitForTransactionService::TimeoutError, 'Transaction not confirmed in time')
  end
end
