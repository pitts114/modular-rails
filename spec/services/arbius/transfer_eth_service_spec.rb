require 'rails_helper'

RSpec.describe Arbius::TransferEthService do
  let(:eth_transfer_service) { double(:eth_transfer_service) }
  let(:miner_model) { double(:miner_model) }
  let(:validator_model) { double(:validator_model) }
  let(:service) do
    described_class.new(
      eth_transfer_service: eth_transfer_service,
      miner_model: miner_model,
      validator_model: validator_model
    )
  end

  let(:from) { '0xMiner1' }
  let(:recipient) { '0xValidator1' }
  let(:amount) { 1_000_000_000_000_000_000 } # 1 ETH in wei

  before do
    allow(eth_transfer_service).to receive(:send_eth)
  end

  describe '#call' do
    context 'when addresses and amount are valid' do
      before do
        allow(miner_model).to receive(:pluck).with(:address).and_return([ from ])
        allow(validator_model).to receive(:pluck).with(:address).and_return([ recipient ])
      end

      it 'calls send_eth on the eth_transfer_service' do
        expect(eth_transfer_service).to receive(:send_eth).with(from: from, to: recipient, amount: amount)
        service.call(from: from, recipient: recipient, amount: amount)
      end
    end

    context 'when sender address is invalid' do
      before do
        allow(miner_model).to receive(:pluck).with(:address).and_return([])
        allow(validator_model).to receive(:pluck).with(:address).and_return([ recipient ])
      end

      it 'raises ArgumentError' do
        expect {
          service.call(from: from, recipient: recipient, amount: amount)
        }.to raise_error(ArgumentError, /Invalid sender address/)
      end
    end

    context 'when recipient address is invalid' do
      before do
        allow(miner_model).to receive(:pluck).with(:address).and_return([ from ])
        allow(validator_model).to receive(:pluck).with(:address).and_return([])
      end

      it 'raises ArgumentError' do
        expect {
          service.call(from: from, recipient: recipient, amount: amount)
        }.to raise_error(ArgumentError, /Invalid recipient address/)
      end
    end

    context 'when amount is not greater than 0' do
      before do
        allow(miner_model).to receive(:pluck).with(:address).and_return([ from ])
        allow(validator_model).to receive(:pluck).with(:address).and_return([ recipient ])
      end

      it 'raises ArgumentError for zero' do
        expect {
          service.call(from: from, recipient: recipient, amount: 0)
        }.to raise_error(ArgumentError, /Amount must be greater than 0/)
      end

      it 'raises ArgumentError for negative' do
        expect {
          service.call(from: from, recipient: recipient, amount: -1)
        }.to raise_error(ArgumentError, /Amount must be greater than 0/)
      end
    end
  end
end
