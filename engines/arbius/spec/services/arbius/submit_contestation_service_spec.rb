# frozen_string_literal: true

require 'rails_helper'

module Arbius
  RSpec.describe SubmitContestationService do
    let(:mock_engine_contract) { double(:engine_contract) }
    let(:service) { described_class.new(engine_contract: mock_engine_contract) }
    let(:from) { '0xabc' }
    let(:taskid) { '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef' }

    it 'calls submit_contestation on the engine contract with context' do
      expected_context = { class: 'Arbius::SubmitContestationService', task_id: taskid, from: from }
      expect(mock_engine_contract).to receive(:submit_contestation).with(from: from, taskid: taskid, context: expected_context)
      service.call(from: from, taskid: taskid)
    end
  end
end
