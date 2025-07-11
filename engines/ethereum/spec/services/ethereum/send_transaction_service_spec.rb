# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::SendTransactionService do
  let(:eth_client) { double(:eth_client, chain_id: chain_id) }
  let(:signer_service) { double(:signer_service) }
  let(:broadcast_service) { double(:broadcast_service) }
  let(:fee_estimator_service) { double(:fee_estimator_service) }
  let(:gas_limit_service) { double(:gas_limit_service) }
  let(:transaction_repository) { double(:transaction_repository) }
  let(:time) { double(:time, current: Time.new(2023, 10, 1, 12, 0, 0)) }
  let(:send_transaction_job) { double(perform_later: nil) }
  let(:transaction_status_publish_service) { double(:transaction_status_publish_service) }
  let(:service) do
    described_class.new(
      eth_client: eth_client,
      signer_service: signer_service,
      broadcast_service: broadcast_service,
      fee_estimator_service: fee_estimator_service,
      gas_limit_service: gas_limit_service,
      transaction_repository: transaction_repository,
      transaction_status_publish_service: transaction_status_publish_service,
      time: time,
      sent_transaction_job: send_transaction_job
    )
  end

  let(:from) { '0xSender' }
  let(:to) { '0xContract' }
  let(:data) { '0xabcdef' }
  let(:value) { 12345 }
  let(:nonce) { 1 }
  let(:chain_id) { 5 }
  let(:fees) { { max_fee_per_gas: 100, max_priority_fee_per_gas: 2 } }
  let(:gas_limit) { 21000 }
  let(:signed_tx) { '0xsignedtx' }
  let(:tx_hash) { '0xtxhash' }
  let(:ethereum_transaction_id) { 123 }
  let(:ethereum_transaction) do
    double(
      id: ethereum_transaction_id,
      from: from,
      to: to,
      data: data,
      value: value,
      status: 'pending',
      context: nil
    )
  end

  let(:address) { from }

  before do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(ethereum_transaction)
    allow(transaction_repository).to receive(:confirmed_transaction_with_highest_nonce).with(from: address, chain_id: chain_id).and_return(nil)
    allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_return({ "result" => nonce.to_s(16) })
    allow(eth_client).to receive(:chain_id).and_return(chain_id)
    allow(fee_estimator_service).to receive(:recommended_fees).and_return(fees)
    allow(gas_limit_service).to receive(:call).with(chain_id: chain_id, from: from, to: to, data: data, value: value).and_return(gas_limit)
    allow(signer_service).to receive(:sign_transaction).and_return(signed_tx)
    allow(broadcast_service).to receive(:send_transaction).with(signed_tx: signed_tx).and_return(tx_hash)
    allow(ethereum_transaction).to receive(:update!)
  end

  it 'calls a contract and broadcasts the transaction and enqueues the job after commit' do
    expect(transaction_repository).to receive(:with_locked_pending_transaction).with(from: address, chain_id: chain_id).and_yield(ethereum_transaction)
    expect(ethereum_transaction).to receive(:update!).with(tx_hash: tx_hash, nonce: nonce, confirmed_at: time.current, status: 'confirmed').ordered
    allow(ethereum_transaction).to receive(:status).and_return('pending')
    expect(transaction_status_publish_service).to receive(:call).with(ethereum_transaction: ethereum_transaction)
    expect(send_transaction_job).to receive(:perform_later).with(address, chain_id)

    result = service.call(address: address, chain_id: chain_id)
    expect(result).to eq(tx_hash)
    expect(gas_limit_service).to have_received(:call).with(chain_id: chain_id, from: from, to: to, data: data, value: value)
    expect(signer_service).to have_received(:sign_transaction)
    expect(broadcast_service).to have_received(:send_transaction).with(signed_tx: signed_tx)
  end

  it 'returns nil if no pending transaction is found' do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(nil)
    expect(transaction_status_publish_service).not_to receive(:call)
    result = service.call(address: address, chain_id: chain_id)
    expect(result).to be_nil
  end

  it 'returns nil if the transaction is not pending' do
    non_pending_transaction = double(id: ethereum_transaction_id, from: from, to: to, data: data, value: value, status: 'confirmed', context: nil)
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(non_pending_transaction)
    expect(transaction_status_publish_service).not_to receive(:call)
    result = service.call(address: address, chain_id: chain_id)
    expect(result).to be_nil
  end

  it 'sets status to failed and re-raises on error' do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(ethereum_transaction)
    allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_raise(StandardError.new('fail'))
    expect(ethereum_transaction).to receive(:update!).with(status: 'failed')
    allow(ethereum_transaction).to receive(:status).and_return('pending')
    expect(transaction_status_publish_service).to receive(:call).with(ethereum_transaction: ethereum_transaction)
    expect(send_transaction_job).to receive(:perform_later).with(address, chain_id)
    expect {
      service.call(address: address, chain_id: chain_id)
    }.to raise_error(Ethereum::SendTransactionService::Error, /Failed to call contract: fail \(StandardError\) - id: 123 - context: nil/)
  end

  it 'does not set status to failed for network errors' do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(ethereum_transaction)
    allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_raise(Errno::ECONNREFUSED)
    expect(ethereum_transaction).not_to receive(:update!)
    allow(ethereum_transaction).to receive(:status).and_return('pending')
    expect(transaction_status_publish_service).to receive(:call).with(ethereum_transaction: ethereum_transaction)
    expect(send_transaction_job).to receive(:perform_later).with(address, chain_id)
    expect {
      service.call(address: address, chain_id: chain_id)
    }.to raise_error(Ethereum::SendTransactionService::Error, /Failed to call contract: Connection refused \(Errno::ECONNREFUSED\) - id: 123 - context: nil/)
  end

  it 'wraps RateLimitedClientWrapper::RateLimitedError in SendTransactionService::Error and does not update status' do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(ethereum_transaction)
    rate_limit_error = Ethereum::RateLimitedClientWrapper::RateLimitedError.new('rate limited!')
    allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_raise(rate_limit_error)
    expect(ethereum_transaction).not_to receive(:update!)
    expect(transaction_status_publish_service).to receive(:call).with(ethereum_transaction: ethereum_transaction)
    expect(send_transaction_job).to receive(:perform_later).with(address, chain_id)
    expect {
      service.call(address: address, chain_id: chain_id)
    }.to raise_error(Ethereum::SendTransactionService::Error, /Failed to call contract: rate limited! \(Ethereum::RateLimitedClientWrapper::RateLimitedError\) - id: 123 - context: nil/)
  end

  it 'does not set status to failed for IOErrors' do
    allow(transaction_repository).to receive(:with_locked_pending_transaction).and_yield(ethereum_transaction)
    allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_raise(IOError.new('disk error'))
    expect(ethereum_transaction).not_to receive(:update!)
    expect(transaction_status_publish_service).to receive(:call).with(ethereum_transaction: ethereum_transaction)
    expect(send_transaction_job).to receive(:perform_later).with(address, chain_id)
    expect {
      service.call(address: address, chain_id: chain_id)
    }.to raise_error(Ethereum::SendTransactionService::Error, /Failed to call contract: disk error \(IOError\) - id: 123 - context: nil/)
  end

  context 'nonce selection' do
    it 'uses the higher of eth_client nonce and repo nonce + 1' do
      allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_return({ "result" => "5" })
      allow(transaction_repository).to receive(:confirmed_transaction_with_highest_nonce).with(from: address, chain_id: chain_id).and_return(double(nonce: 7))
      expect(signer_service).to receive(:sign_transaction) do |args|
        expect(args[:tx][:nonce]).to eq(8)
      end.and_return(signed_tx)
      allow(broadcast_service).to receive(:send_transaction).and_return(tx_hash)
      allow(ethereum_transaction).to receive(:update!)
      allow(transaction_status_publish_service).to receive(:call)
      service.call(address: address, chain_id: chain_id)
    end

    it 'uses eth_client nonce if it is higher than repo nonce + 1' do
      allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_return({ "result" => "a" }) # 10 in hex
      allow(transaction_repository).to receive(:confirmed_transaction_with_highest_nonce).with(from: address, chain_id: chain_id).and_return(double(nonce: 3))
      expect(signer_service).to receive(:sign_transaction) do |args|
        expect(args[:tx][:nonce]).to eq(10)
      end.and_return(signed_tx)
      allow(broadcast_service).to receive(:send_transaction).and_return(tx_hash)
      allow(ethereum_transaction).to receive(:update!)
      allow(transaction_status_publish_service).to receive(:call)
      service.call(address: address, chain_id: chain_id)
    end

    it 'uses 1 if repo nonce is nil' do
      allow(eth_client).to receive(:eth_get_transaction_count).with(address, "pending").and_return({ "result" => "1" })
      allow(transaction_repository).to receive(:confirmed_transaction_with_highest_nonce).with(from: address, chain_id: chain_id).and_return(nil)
      expect(signer_service).to receive(:sign_transaction) do |args|
        expect(args[:tx][:nonce]).to eq(1)
      end.and_return(signed_tx)
      allow(broadcast_service).to receive(:send_transaction).and_return(tx_hash)
      allow(ethereum_transaction).to receive(:update!)
      allow(transaction_status_publish_service).to receive(:call)
      service.call(address: address, chain_id: chain_id)
    end
  end
end
