# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arbius::WaiBulkBogusAutoMineSchedulerService, type: :service do
  let(:job_execution_tracker_repository) { double(:job_execution_tracker_repository) }
  let(:time) { double(:time) }
  let(:current_time) { Time.parse("2023-07-07 12:00:00") }
  let(:tracker) { double(:tracker) }

  let(:service) do
    described_class.new(
      job_execution_tracker_repository: job_execution_tracker_repository,
      time: time
    )
  end

  before do
    allow(time).to receive(:current).and_return(current_time)
    allow(job_execution_tracker_repository).to receive(:with_locked_tracker).and_yield(tracker)
  end

  describe "#call" do
    context "when enough time has passed" do
      let(:last_executed_at) { current_time - 2.hours }

      before do
        allow(tracker).to receive(:last_executed_at).and_return(last_executed_at)
        stub_const("ENV", ENV.to_hash.merge("ARBIUS_WAI_BULK_BOGUS_AUTO_MINE_INTERVAL_SECONDS" => "3600"))
      end

      it "updates the tracker and enqueues the job" do
        expect(tracker).to receive(:update!).with(last_executed_at: current_time)
        expect(Arbius::WaiBulkBogusAutoMineJob).to receive(:perform_later)
        service.call
      end

      it "calls the repository with the correct job name" do
        expect(job_execution_tracker_repository).to receive(:with_locked_tracker)
          .with(job_name: "WaiBulkBogusAutoMineJob")
        allow(tracker).to receive(:update!)
        allow(Arbius::WaiBulkBogusAutoMineJob).to receive(:perform_later)
        service.call
      end
    end

    context "when not enough time has passed" do
      let(:last_executed_at) { current_time - 30.minutes }

      before do
        allow(tracker).to receive(:last_executed_at).and_return(last_executed_at)
        stub_const("ENV", ENV.to_hash.merge("ARBIUS_WAI_BULK_BOGUS_AUTO_MINE_INTERVAL_SECONDS" => "3600"))
      end

      it "does not update the tracker or enqueue the job" do
        expect(tracker).not_to receive(:update!)
        expect(Arbius::WaiBulkBogusAutoMineJob).not_to receive(:perform_later)
        service.call
      end
    end

    context "when interval environment variable is not set" do
      let(:last_executed_at) { current_time - 2.hours }

      before do
        allow(tracker).to receive(:last_executed_at).and_return(last_executed_at)
        stub_const("ENV", ENV.to_hash.except("ARBIUS_WAI_BULK_BOGUS_AUTO_MINE_INTERVAL_SECONDS"))
      end

      it "uses default interval of 3600 seconds" do
        expect(tracker).to receive(:update!).with(last_executed_at: current_time)
        expect(Arbius::WaiBulkBogusAutoMineJob).to receive(:perform_later)
        service.call
      end
    end

    context "when interval environment variable is set to custom value" do
      let(:last_executed_at) { current_time - 10.minutes }

      before do
        allow(tracker).to receive(:last_executed_at).and_return(last_executed_at)
        stub_const("ENV", ENV.to_hash.merge("ARBIUS_WAI_BULK_BOGUS_AUTO_MINE_INTERVAL_SECONDS" => "300"))
      end

      it "uses the custom interval" do
        expect(tracker).to receive(:update!).with(last_executed_at: current_time)
        expect(Arbius::WaiBulkBogusAutoMineJob).to receive(:perform_later)
        service.call
      end
    end
  end
end
