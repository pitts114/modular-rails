# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arbius::JobExecutionTracker, type: :model do
  describe "validations" do
    it "validates presence of job_name" do
      tracker = described_class.new(last_executed_at: Time.current)
      expect(tracker).not_to be_valid
      expect(tracker.errors[:job_name]).to include("can't be blank")
    end

    it "validates uniqueness of job_name" do
      create(:job_execution_tracker, job_name: "TestJob")
      tracker = described_class.new(job_name: "TestJob", last_executed_at: Time.current)
      expect(tracker).not_to be_valid
      expect(tracker.errors[:job_name]).to include("has already been taken")
    end

    it "validates presence of last_executed_at" do
      tracker = described_class.new(job_name: "TestJob")
      expect(tracker).not_to be_valid
      expect(tracker.errors[:last_executed_at]).to include("can't be blank")
    end
  end

  describe "valid tracker" do
    it "creates a valid tracker with all required fields" do
      tracker = described_class.new(
        job_name: "TestJob",
        last_executed_at: Time.current
      )
      expect(tracker).to be_valid
    end
  end
end
