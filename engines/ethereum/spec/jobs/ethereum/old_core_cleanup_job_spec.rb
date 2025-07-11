# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ethereum::OldCoreCleanupJob, type: :job do
  it "calls the OldCoreCleanupService" do
    expect(Ethereum::OldCoreCleanupService).to receive(:call)
    described_class.perform_now
  end
end
