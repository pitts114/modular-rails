require 'json'

module Arbius
  class HighPrioritySolutionSubmittedJob < ApplicationJob
    queue_as :arbius_event_handler_high_priority

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::SolutionSubmittedService.new.call(payload:)
    end
  end
end
