# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::TransactionSignerService do
  let(:vault_client) { double(:vault_client) }
  let(:eth_tx) { double(:eth_tx, hex: 'deadbeef') }
    let(:eth_tx_class) do
    double(:eth_tx_class, decode_hex: eth_tx, new: eth_tx)
  end
  let(:service) { described_class.new(vault_client: vault_client, eth_tx_class: eth_tx_class) }
  let(:address) { '0x123' }
  let(:tx) { eth_tx }

  describe '#sign_transaction' do
    it 'calls the vault client and returns a signed tx' do
      tx_data = { foo: 'bar' }
      expect(vault_client).to receive(:sign_tx).with(address: address, tx: tx_data)
        .and_return({ 'signed_transaction' => 'deadbeef' })
      allow(eth_tx_class).to receive(:decode).with('deadbeef').and_return(eth_tx)
      signed = service.sign_transaction(tx: tx_data, address: address)
      expect(signed).to eq(eth_tx)
    end

    it 'raises if vault does not return signed_tx' do
      allow(eth_tx).to receive(:unsigned_encoded).and_return('')
      expect(vault_client).to receive(:sign_tx).and_return({ 'error' => 'nope' })
      expect {
        service.sign_transaction(tx: eth_tx, address: address)
      }.to raise_error(Ethereum::TransactionSignerService::Error)
    end
  end
end
