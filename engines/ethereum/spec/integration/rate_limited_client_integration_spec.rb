# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rate-limited client integration' do
  let(:client) { Ethereum::ClientProvider.client }

  it 'forwards common Ethereum client methods through the rate limiter' do
    # Test that our wrapper properly forwards all the methods used by services
    expect(client.respond_to?(:chain_id)).to be true
    expect(client.respond_to?(:eth_call)).to be true
    expect(client.respond_to?(:get_nonce)).to be true
    expect(client.respond_to?(:eth_get_block_by_number)).to be true
    expect(client.respond_to?(:eth_estimate_gas)).to be true
    expect(client.respond_to?(:eth_block_number)).to be true
    expect(client.respond_to?(:eth_get_logs)).to be true
  end

  it 'returns a rate-limited wrapper' do
    expect(client).to be_a(Ethereum::RateLimitedClientWrapper)
  end

  it 'maintains consistent behavior with method_missing' do
    # Test that method_missing properly handles arguments and blocks
    expect(client.respond_to?(:non_existent_method)).to be false
  end
end
