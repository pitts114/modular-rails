# frozen_string_literal: true

module Arbius
  class JobExecutionTracker < Arbius::ApplicationRecord
    validates :job_name, presence: true, uniqueness: true
    validates :last_executed_at, presence: true
  end
end
