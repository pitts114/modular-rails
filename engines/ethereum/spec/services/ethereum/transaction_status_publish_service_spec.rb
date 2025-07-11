require 'rails_helper'

RSpec.describe Ethereum::TransactionStatusPublishService do
  let(:notifications) { double(:notifications) }
  let(:service) { described_class.new(notifications: notifications) }

  describe '#call' do
    let(:ethereum_transaction) do
      double(:ethereum_transaction,
        id: 'tx-123',
        from: '0x1234567890123456789012345678901234567890',
        to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef',
        tx_hash: '0xhash123',
        chain_id: 1,
        context: { class: 'Arbius::VoteOnContestationService', task_id: 'task-123', from: '0x1234567890123456789012345678901234567890' }
      )
    end

    context 'when transaction status is confirmed' do
      before do
        allow(ethereum_transaction).to receive(:status).and_return('confirmed')
      end

      it 'publishes a transaction status event' do
        expected_payload = {
          ethereum_transaction_id: 'tx-123',
          from: '0x1234567890123456789012345678901234567890',
          to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef',
          tx_hash: '0xhash123',
          status: 'confirmed',
          chain_id: 1,
          context: { class: 'Arbius::VoteOnContestationService', task_id: 'task-123', from: '0x1234567890123456789012345678901234567890' }
        }

        expect(notifications).to receive(:instrument).with('ethereum.transaction_status_updated', expected_payload)

        service.call(ethereum_transaction: ethereum_transaction)
      end
    end

    context 'when transaction status is failed' do
      before do
        allow(ethereum_transaction).to receive(:status).and_return('failed')
      end

      it 'publishes a transaction status event' do
        expected_payload = {
          ethereum_transaction_id: 'tx-123',
          from: '0x1234567890123456789012345678901234567890',
          to: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef',
          tx_hash: '0xhash123',
          status: 'failed',
          chain_id: 1,
          context: { class: 'Arbius::VoteOnContestationService', task_id: 'task-123', from: '0x1234567890123456789012345678901234567890' }
        }

        expect(notifications).to receive(:instrument).with('ethereum.transaction_status_updated', expected_payload)

        service.call(ethereum_transaction: ethereum_transaction)
      end
    end

    context 'when transaction status is pending' do
      before do
        allow(ethereum_transaction).to receive(:status).and_return('pending')
      end

      it 'does not publish an event' do
        expect(notifications).not_to receive(:instrument)

        service.call(ethereum_transaction: ethereum_transaction)
      end
    end

    context 'when transaction status is broadcasted' do
      before do
        allow(ethereum_transaction).to receive(:status).and_return('broadcasted')
      end

      it 'does not publish an event' do
        expect(notifications).not_to receive(:instrument)

        service.call(ethereum_transaction: ethereum_transaction)
      end
    end
  end
end
