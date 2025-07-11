# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arbius::WaiBulkBogusAutoMineSchedulerJob, type: :job do
  let(:service_double) { double(:wai_bulk_bogus_auto_mine_scheduler_service) }

  before do
    allow(Arbius::WaiBulkBogusAutoMineSchedulerService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:call)
  end

  it "calls the WaiBulkBogusAutoMineSchedulerService" do
    expect(Arbius::WaiBulkBogusAutoMineSchedulerService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call)
    described_class.perform_now
  end
end
