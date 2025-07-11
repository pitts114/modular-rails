# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arbius::OldEventCleanupJob, type: :job do
  it "calls the OldEventCleanupService" do
    expect(Arbius::OldEventCleanupService).to receive(:call)
    described_class.perform_now
  end
end
