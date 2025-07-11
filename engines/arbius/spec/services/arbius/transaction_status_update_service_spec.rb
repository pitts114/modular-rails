require 'rails_helper'

RSpec.describe Arbius::TransactionStatusUpdateService do
  let(:sent_contestation_vote_model) { double(:sent_contestation_vote_model) }
  let(:logger) { double(:logger) }
  let(:defend_solution_job) { double(:defend_solution_job, perform_later: nil) }
  let(:handler) { described_class.new(sent_contestation_vote_model: sent_contestation_vote_model, logger: logger, defend_solution_job: defend_solution_job) }

  describe '#call' do
    let(:from_address) { '0x1234567890123456789012345678901234567890' }
    let(:task_id) { 'task-123' }
    let(:context) { { class: 'Arbius::VoteOnContestationService', task_id: task_id, from: from_address, yea: false } }

    context 'when transaction is confirmed' do
      let(:payload) do
        {
          from: from_address,
          status: 'confirmed',
          context: context
        }
      end

      it 'updates the sent contestation vote status to confirmed and does not enqueue defend solution job' do
        sent_vote = double(:sent_vote)
        allow(sent_contestation_vote_model).to receive(:find_by).with(address: from_address, task: task_id).and_return(sent_vote)
        expect(sent_vote).to receive(:update!).with(status: 'confirmed')
        expect(logger).to receive(:info).with("[TransactionStatusHandler] Updated contestation vote status to confirmed for address: #{from_address}, task: #{task_id}")
        expect(defend_solution_job).not_to receive(:perform_later)

        handler.call(payload: payload)
      end
    end

    context 'when transaction is failed' do
      let(:payload) do
        {
          from: from_address,
          status: 'failed',
          context: context
        }
      end

      it 'updates the sent contestation vote status to failed and enqueues defend solution job' do
        sent_vote = double(:sent_vote)
        allow(sent_contestation_vote_model).to receive(:find_by).with(address: from_address, task: task_id).and_return(sent_vote)
        expect(sent_vote).to receive(:update!).with(status: 'failed')
        expect(logger).to receive(:info).with("[TransactionStatusHandler] Updated contestation vote status to failed for address: #{from_address}, task: #{task_id}")
        expect(defend_solution_job).to receive(:perform_later).with(task_id)

        handler.call(payload: payload)
      end
    end

    context 'when sent contestation vote is not found' do
      let(:payload) do
        {
          from: from_address,
          status: 'confirmed',
          context: context
        }
      end

      it 'logs a warning and does not enqueue defend solution job' do
        allow(sent_contestation_vote_model).to receive(:find_by).with(address: from_address, task: task_id).and_return(nil)
        expect(logger).to receive(:warn).with("[TransactionStatusHandler] Could not find SentContestationVoteEvent for address: #{from_address}, task: #{task_id}")
        expect(defend_solution_job).not_to receive(:perform_later)

        handler.call(payload: payload)
      end
    end

    context 'when context class is not VoteOnContestationService' do
      let(:payload) do
        {
          from: from_address,
          status: 'confirmed',
          context: { class: 'SomeOtherService', task_id: task_id, from: from_address }
        }
      end

      it 'does not process the event or enqueue defend solution job' do
        expect(sent_contestation_vote_model).not_to receive(:find_by)
        expect(logger).not_to receive(:info)
        expect(defend_solution_job).not_to receive(:perform_later)

        handler.call(payload: payload)
      end
    end

    context 'when context is nil' do
      let(:payload) do
        {
          from: from_address,
          status: 'confirmed',
          context: nil
        }
      end

      it 'does not process the event or enqueue defend solution job' do
        expect(sent_contestation_vote_model).not_to receive(:find_by)
        expect(logger).not_to receive(:info)
        expect(defend_solution_job).not_to receive(:perform_later)

        handler.call(payload: payload)
      end
    end

    context 'when context class is Arbius::SubmitContestationService' do
      let(:context) { { class: 'Arbius::SubmitContestationService', task_id: task_id, from: from_address } }
      let(:payload) do
        {
          from: from_address,
          status: 'confirmed',
          context: context
        }
      end

      it 'processes the event (updates status) for SubmitContestationService' do
        sent_vote = double(:sent_vote)
        allow(sent_contestation_vote_model).to receive(:find_by).with(address: from_address, task: task_id).and_return(sent_vote)
        expect(sent_vote).to receive(:update!).with(status: 'confirmed')
        expect(logger).to receive(:info).with("[TransactionStatusHandler] Updated contestation vote status to confirmed for address: #{from_address}, task: #{task_id}")
        expect(defend_solution_job).not_to receive(:perform_later)

        handler.call(payload: payload)
      end
    end
  end
end
