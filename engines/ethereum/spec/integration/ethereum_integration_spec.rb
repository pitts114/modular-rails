# frozen_string_literal: true

require 'rails_helper'
require 'eth'

RSpec.describe 'Ethereum Integration', type: :integration do
  let(:from) { '0xb532a213B0d1fBC21D49EA44973E13351Bd1609e' }
  let(:to) { '0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69' }
  let(:amount) { Eth::Unit::FINNEY.to_i } # 0.001 ETH

  before do
    unless ENV['RUN_ETHEREUM_INTEGRATION'] == 'true'
      skip 'Ethereum integration tests are skipped unless RUN_ETHEREUM_INTEGRATION=true'
    end
  end

  describe 'ETH transfer' do
    def get_balance(address)
      Ethereum::ClientProvider.client.get_balance(address)
    end

    it 'sends 0.001 ETH from one address to another' do
      balance_from_before = get_balance(from)
      balance_to_before = get_balance(to)

      Ethereum::Public::EthTransferService.new.send_eth(from: from, to: to, amount: amount)

      while job = Resque.reserve(:default)
        job.perform
      end

      sleep 3

      balance_from_after = get_balance(from)
      balance_to_after = get_balance(to)

      expect(balance_to_after - balance_to_before).to eq(amount)
      expect(balance_from_before - balance_from_after).to be >= amount
    end
  end
end
