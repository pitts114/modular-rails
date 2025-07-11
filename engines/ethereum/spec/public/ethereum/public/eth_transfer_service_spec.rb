# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Public::EthTransferService do
  let(:eth_client) { double(:eth_client, chain_id: 123) }
  let(:send_transaction_job) { double(:send_transaction_job) }
  let(:ethereum_transaction_model) { double(:ethereum_transaction_model) }
  let(:service) do
    described_class.new(
      eth_client: eth_client,
      send_transaction_job: send_transaction_job,
      ethereum_transaction_model: ethereum_transaction_model
    )
  end

  describe '#send_eth' do
    let(:from) { '0xabc' }
    let(:to) { '0xdef' }
    let(:amount) { 42 }

    it 'creates a pending transaction and enqueues the job, returning the new record id' do
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: from,
        to: to,
        data: '',
        value: amount,
        status: 'pending',
        chain_id: 123
      ).and_return(double(id: 456))
      expect(send_transaction_job).to receive(:perform_later).with(from, 123)
      result = service.send_eth(from: from, to: to, amount: amount)
      expect(result).to eq(456)
    end
  end
end
