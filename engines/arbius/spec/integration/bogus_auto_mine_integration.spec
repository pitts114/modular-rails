# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bogus Auto Mine Integration', type: :integration do
  let(:from) { '0xb532a213B0d1fBC21D49EA44973E13351Bd1609e' }
  let(:model) { '0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a' }
  let(:fee) { 1_000_000_000_000_000 } # 0.001 in wei
  let(:input) { { "prompt": "abc123" } }

  before do
    unless ENV['RUN_ETHEREUM_INTEGRATION'] == 'true'
      skip 'Ethereum integration tests are skipped unless RUN_ETHEREUM_INTEGRATION=true'
    end
  end

  it 'submits a task and bogus mines a solution for it' do
    service = Arbius::BogusAutoMineService.new
    expect {
      service.call(from: from, model: model, fee: fee, input: input)
    }.not_to raise_error
    # Optionally, add assertions to check the task and solution state if accessible
  end
end
