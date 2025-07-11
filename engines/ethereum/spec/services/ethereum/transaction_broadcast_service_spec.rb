# frozen_string_literal: true

require 'rails_helper'
require 'eth'

RSpec.describe Ethereum::TransactionBroadcastService do
  let(:eth_client) { instance_double(Eth::Client) }
  let(:service) { described_class.new(eth_client: eth_client) }
  let(:signed_tx) { double('Eth::Tx', hex: 'deadbeef') }
  let(:tx_hash) { '0x123abc' }

  describe '#send_transaction' do
    it 'broadcasts and waits for mining by default (using tx_mined?)' do
      allow(signed_tx).to receive(:hex).and_return('deadbeef')
      allow(eth_client).to receive(:eth_send_raw_transaction).with('deadbeef').and_return({ 'result' => tx_hash })
      allow(eth_client).to receive(:tx_mined?).with(tx_hash).and_return(false, true)
      expect(service.send_transaction(signed_tx: signed_tx, poll_interval: 0)).to eq(tx_hash)
    end

    it 'raises BroadcastError if broadcasting fails' do
      allow(signed_tx).to receive(:hex).and_return('deadbeef')
      allow(eth_client).to receive(:eth_send_raw_transaction).with('deadbeef').and_return({ 'error' => 'fail' })
      expect {
        service.send_transaction(signed_tx: signed_tx)
      }.to raise_error(Ethereum::TransactionBroadcastService::BroadcastError)
    end

    it 'raises TimeoutError if not mined in time' do
      allow(signed_tx).to receive(:hex).and_return('deadbeef')
      allow(eth_client).to receive(:eth_send_raw_transaction).with('deadbeef').and_return({ 'result' => tx_hash })
      allow(eth_client).to receive(:tx_mined?).with(tx_hash).and_return(false, false, false)
      expect {
        service.send_transaction(signed_tx: signed_tx, timeout: 0.01, poll_interval: 0)
      }.to raise_error(Ethereum::TransactionBroadcastService::TimeoutError)
    end

    it 'does not wait for mining if wait: false' do
      allow(signed_tx).to receive(:hex).and_return('deadbeef')
      allow(eth_client).to receive(:eth_send_raw_transaction).with('deadbeef').and_return({ 'result' => tx_hash })
      expect(eth_client).not_to receive(:tx_mined?)
      expect(service.send_transaction(signed_tx: signed_tx, wait: false)).to eq(tx_hash)
    end
  end
end
