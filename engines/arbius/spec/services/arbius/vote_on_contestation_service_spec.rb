# frozen_string_literal: true

require 'rails_helper'

module Arbius
  RSpec.describe VoteOnContestationService do
    let(:engine_contract) { double(:engine_contract) }
    let(:service) { described_class.new(engine_contract: engine_contract) }

    describe '#call' do
      let(:from) { '0x123' }
      let(:task_id) { 42 }
      let(:yea) { true }

      it 'calls vote_on_contestation on the engine_contract with correct arguments and context' do
        expected_context = { class: 'Arbius::VoteOnContestationService', task_id: task_id, from: from, yea: yea }
        expect(engine_contract).to receive(:vote_on_contestation).with(from: from, taskid: task_id, yea: yea, context: expected_context)
        service.call(from: from, task_id: task_id, yea: yea)
      end
    end
  end
end
