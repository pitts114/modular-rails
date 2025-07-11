# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BogusMineService do
  let(:mock_mine_solution_service) { double(:mine_solution_service) }
  let(:service) { described_class.new(mine_solution_service: mock_mine_solution_service) }

  it 'generates a random cid and calls MineSolutionService with correct arguments' do
    from = '0xabc'
    taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
    expect(mock_mine_solution_service).to receive(:call) do |args|
      expect(args[:from]).to eq(from)
      expect(args[:taskid]).to eq(taskid)
      expect(args[:cid]).to match(/^0x[0-9a-f]{64}$/)
    end
    service.call(from: from, taskid: taskid)
  end
end
