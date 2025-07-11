require 'rails_helper'

RSpec.describe Arbius::TransferAiusService do
  let(:aius_contract) { double(:aius_contract) }
  let(:miner_model) { double(:miner_model) }
  let(:validator_model) { double(:validator_model) }
  let(:service) do
    described_class.new(
      aius_contract: aius_contract,
      miner_model: miner_model,
      validator_model: validator_model
    )
  end

  let(:from) { '0xMiner1' }
  let(:recipient) { '0xValidator1' }
  let(:amount) { 100 }

  before do
    allow(aius_contract).to receive(:transfer)
  end

  describe '#call' do
    context 'when addresses and amount are valid' do
      before do
        allow(miner_model).to receive(:pluck).with(:address).and_return([ from ])
        allow(validator_model).to receive(:pluck).with(:address).and_return([ recipient ])
      end

      it 'calls transfer on the contract' do
        expect(aius_contract).to receive(:transfer).with(from: from, recipient: recipient, amount: amount)
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
