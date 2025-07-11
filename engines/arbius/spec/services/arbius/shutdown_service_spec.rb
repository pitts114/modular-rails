# frozen_string_literal: true

require 'rails_helper'

describe Arbius::ShutdownService do
  let(:flipper) { double(:flipper) }
  subject(:service) { described_class.new(flipper: flipper) }

  it 'disables feature flags' do
    expect(flipper).to receive(:disable).with(:defend_solution)
    expect(flipper).to receive(:disable).with(:bulk_bogus_auto_mine)
    expect(flipper).to receive(:disable).with(:attack_solution)
    service.call
  end
end
