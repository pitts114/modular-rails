require 'json'

module Arbius
  class SolutionSubmittedJob < ApplicationJob
    queue_as :arbius_event_handler

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::SolutionSubmittedService.new.call(payload:)
    end
  end
end
