# frozen_string_literal: true

require 'rspec'
require 'dotenv/load'
require 'eth'
require_relative '../../lib/vault_client'

RSpec.describe VaultClient::VaultClient, type: :integration do
  let(:host) { ENV.fetch('VAULT_HOST', 'localhost') }
  let(:port) { ENV.fetch('VAULT_PORT', 3000).to_i }
  let(:api_secret) { ENV.fetch('VAULT_API_SECRET') }
  let(:address) { '0x2E6139691C1a04263812dD76A3e48c66AFdfec9A' }
  let(:message) { 'integration test message' }
  let(:tx_data) do
    {
      'nonce' => 1,
      'to' => address,
      'value' => 1000,
      'gas_limit' => 21_000,
      'gas_price' => 50_000_000_000,
      'chain_id' => 1
    }
  end
  let(:client) { described_class.new(host: host, port: port, api_secret: api_secret) }

  it 'signs a message via the client and verifies the signature' do
    result = client.sign_msg(address: address, message: message)
    expect(result['signature']).not_to be_nil
    sig = result['signature']
    expect(Eth::Signature.verify(message, sig, address)).to be true
  end

  it 'raises error if Authorization is wrong' do
    bad_client = described_class.new(host: host, port: port, api_secret: 'wrongsecret')
    expect {
      bad_client.sign_msg(address: address, message: message)
    }.to raise_error(VaultClient::Error, /Unauthorized/)
  end

  it 'raises error if address is not in the vault' do
    expect {
      client.sign_msg(address: '0x000000000000000000000000000000000000dead', message: message)
    }.to raise_error(VaultClient::Error, /Key not found/i)
  end

  it 'signs a transaction via the client and returns a valid hex string' do
    result = client.sign_tx(address: address, tx: tx_data)
    expect(result['signed_transaction']).not_to be_nil
    expect(result['signed_transaction']).to match(/^0x[0-9a-fA-F]+$/)
  end
end
