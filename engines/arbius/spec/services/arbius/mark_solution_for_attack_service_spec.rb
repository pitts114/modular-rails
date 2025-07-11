# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::MarkSolutionForAttackService do
  let(:attack_solution_model) { double(:attack_solution_model) }
  let(:solution_submitted_event_model) { double(:solution_submitted_event_model) }
  let(:submit_contestation_service) { double(:submit_contestation_service) }
  let(:miner_model) { double(:miner_model) }
  let(:miner) { double(:miner, address: '0xabc') }
  let(:service) do
    described_class.new(
      attack_solution_model: attack_solution_model,
      solution_submitted_event_model: solution_submitted_event_model,
      submit_contestation_service: submit_contestation_service,
      miner_model: miner_model
    )
  end
  let(:task_id) { 123 }

  describe '#call' do
    context 'when SolutionSubmittedEvent exists' do
      let(:event) { double(:solution_submitted_event) }

      before do
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(event)
        allow(attack_solution_model).to receive(:create!).with(task: task_id)
        allow(miner_model).to receive(:first).and_return(miner)
        allow(submit_contestation_service).to receive(:call)
      end

      it 'creates an AttackSolution and calls SubmitContestationService' do
        expect(attack_solution_model).to receive(:create!).with(task: task_id)
        expect(miner_model).to receive(:first).and_return(miner)
        expect(submit_contestation_service).to receive(:call).with(from: '0xabc', taskid: task_id)
        service.call(task_id: task_id)
      end
    end

    context 'when SolutionSubmittedEvent does not exist' do
      before do
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(nil)
      end

      it 'raises SolutionSubmittedEventNotFoundError' do
        expect {
          service.call(task_id: task_id)
        }.to raise_error(described_class::SolutionSubmittedEventNotFoundError)
      end
    end
  end
end
