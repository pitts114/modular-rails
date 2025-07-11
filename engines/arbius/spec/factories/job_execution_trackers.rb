# frozen_string_literal: true

FactoryBot.define do
  factory :job_execution_tracker, class: "Arbius::JobExecutionTracker" do
    job_name { "TestJob" }
    last_executed_at { Time.current }
  end
end
