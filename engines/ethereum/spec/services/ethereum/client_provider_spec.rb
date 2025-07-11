# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::ClientProvider do
  describe '.client' do
    it 'returns a rate limited wrapper around Eth::Client' do
      client = described_class.client
      expect(client).to be_a(Ethereum::RateLimitedClientWrapper)
    end

    it 'returns the same instance on multiple calls' do
     client1 = described_class.client
     client2 = described_class.client
     expect(client1).to equal(client2)
    end

    it 'forwards method calls to the underlying Eth::Client' do
      client = described_class.client
      # Test that it responds to common Eth::Client methods
      expect(client.respond_to?(:chain_id)).to be true
      expect(client.respond_to?(:eth_block_number)).to be true
      expect(client.respond_to?(:get_balance)).to be true
    end
  end
end
