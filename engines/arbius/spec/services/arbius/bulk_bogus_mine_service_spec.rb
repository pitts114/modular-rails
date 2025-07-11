# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkBogusMineService do
  let(:mock_mine_solution_service) { double(:mine_solution_service) }
  let(:service) { described_class.new(mine_solution_service: mock_mine_solution_service) }

  it 'calls BulkMineSolutionService with random fake CIDs for each taskid' do
    from = '0xabc'
    taskids = [
      '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    ]
    # We want to control randomness for test predictability
    fake_cids = [ '0x' + 'a'*64, '0x' + 'b'*64 ]
    allow(SecureRandom).to receive(:hex).with(32).and_return('a'*64, 'b'*64)
    expect(mock_mine_solution_service).to receive(:call).with(from: from, taskids: taskids, cids: fake_cids)
    service.call(from: from, taskids: taskids)
  end
end
