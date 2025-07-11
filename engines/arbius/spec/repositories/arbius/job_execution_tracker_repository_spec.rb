# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arbius::JobExecutionTrackerRepository, type: :repository do
  describe ".with_locked_tracker" do
    let(:job_name) { "TestJob" }

    context "when tracker exists" do
      let!(:tracker) { create(:job_execution_tracker, job_name: job_name) }

      it "yields the existing tracker" do
        yielded_tracker = nil
        described_class.with_locked_tracker(job_name: job_name) do |t|
          yielded_tracker = t
        end
        expect(yielded_tracker).to eq(tracker)
      end

      it "locks the tracker record" do
        expect(Arbius::JobExecutionTracker).to receive(:lock).with(true).and_call_original
        described_class.with_locked_tracker(job_name: job_name) { |t| t }
      end
    end

    context "when tracker does not exist" do
      it "creates a new tracker" do
        expect {
          described_class.with_locked_tracker(job_name: job_name) { |t| t }
        }.to change(Arbius::JobExecutionTracker, :count).by(1)
      end

      it "yields the newly created tracker" do
        yielded_tracker = nil
        described_class.with_locked_tracker(job_name: job_name) do |t|
          yielded_tracker = t
        end
        expect(yielded_tracker.job_name).to eq(job_name)
        expect(yielded_tracker).to be_persisted
      end

      it "sets last_executed_at to current time" do
        current_time = Time.current
        allow(Time).to receive(:current).and_return(current_time)

        yielded_tracker = nil
        described_class.with_locked_tracker(job_name: job_name) do |t|
          yielded_tracker = t
        end
        expect(yielded_tracker.last_executed_at).to eq(current_time)
      end
    end

    it "runs within a transaction" do
      expect(Arbius::JobExecutionTracker).to receive(:transaction).and_call_original
      described_class.with_locked_tracker(job_name: job_name) { |t| t }
    end
  end
end
