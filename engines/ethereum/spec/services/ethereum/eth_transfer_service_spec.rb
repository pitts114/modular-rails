# frozen_string_literal: true

require 'rails_helper'
require 'eth'

RSpec.describe Ethereum::EthTransferService do
  let(:signer_service) { double(:transaction_signer_service) }
  let(:broadcast_service) { double(:transaction_broadcast_service) }
  let(:eth_client) { double(:eth_client) }
  let(:fee_estimator_service) { double(:fee_estimator_service) }
  let(:gas_limit_service) { double(:gas_limit_service) }
  let(:service) do
    described_class.new(
      signer_service: signer_service,
      broadcast_service: broadcast_service,
      fee_estimator_service: fee_estimator_service,
      eth_client: eth_client,
      gas_limit_service: gas_limit_service
    )
  end

  let(:from) { '0xabc' }
  let(:to) { '0xdef' }
  let(:amount) { 1_000_000_000_000_000_000 } # 1 ETH in wei
  let(:nonce) { 5 }
  let(:gas_price) { 42_000_000_000 }
  let(:chain_id) { 1 }
  let(:tx) { double(:eth_tx, hex: 'deadbeef') }
  let(:signed_tx) { double(:eth_tx, hex: 'cafebabe') }
  let(:tx_hash) { '0x123abc' }

  before do
    allow(eth_client).to receive(:eth_get_transaction_count).with(from, "pending").and_return({ "result" => nonce.to_s(16) })
    allow(eth_client).to receive(:gas_price).and_return(gas_price)
    allow(eth_client).to receive(:chain_id).and_return(chain_id)
    allow(Eth::Tx).to receive(:new).with(
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: 21_000,
      to: to,
      value: amount,
      data: '',
      chain_id: chain_id
    ).and_return(tx)
  end

  describe '#send_eth' do
    it 'builds, signs, and broadcasts a transaction' do
      fees = { max_fee_per_gas: 2_200_000_000, max_priority_fee_per_gas: 2_000_000_000 }
      expect(fee_estimator_service).to receive(:recommended_fees).and_return(fees)
      gas_limit = 21_000
      expect(gas_limit_service).to receive(:for_eth_transfer).with(chain_id: chain_id).and_return(gas_limit)
      expected_tx_hash = {
        chain_id: chain_id,
        nonce: nonce,
        to: to,
        value: amount,
        gas_limit: gas_limit,
        priority_fee: fees[:max_priority_fee_per_gas],
        max_gas_fee: fees[:max_fee_per_gas],
        access_list: [],
        data: ''
      }
      expect(signer_service).to receive(:sign_transaction).with(tx: expected_tx_hash, address: from).and_return(signed_tx)
      expect(broadcast_service).to receive(:send_transaction).with(signed_tx: signed_tx).and_return(tx_hash)
      expect(service.send_eth(from: from, to: to, amount: amount)).to eq(tx_hash)
    end

    it 'raises an error if signing fails' do
      fees = { max_fee_per_gas: 2_200_000_000, max_priority_fee_per_gas: 2_000_000_000 }
      allow(fee_estimator_service).to receive(:recommended_fees).and_return(fees)
      allow(gas_limit_service).to receive(:for_eth_transfer).with(chain_id: chain_id).and_return(21_000)
      allow(signer_service).to receive(:sign_transaction).and_raise(StandardError, 'signing failed')
      expect {
        service.send_eth(from: from, to: to, amount: amount)
      }.to raise_error(Ethereum::EthTransferService::Error, /signing failed/)
    end

    it 'raises an error if broadcasting fails' do
      fees = { max_fee_per_gas: 2_200_000_000, max_priority_fee_per_gas: 2_000_000_000 }
      allow(fee_estimator_service).to receive(:recommended_fees).and_return(fees)
      allow(gas_limit_service).to receive(:for_eth_transfer).with(chain_id: chain_id).and_return(21_000)
      allow(signer_service).to receive(:sign_transaction).and_return(signed_tx)
      allow(broadcast_service).to receive(:send_transaction).and_raise(StandardError, 'broadcast failed')
      expect {
        service.send_eth(from: from, to: to, amount: amount)
      }.to raise_error(Ethereum::EthTransferService::Error, /broadcast failed/)
    end
  end
end
