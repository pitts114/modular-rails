require 'json'

module Arbius
  class ContestationSubmittedJob < ApplicationJob
    queue_as :arbius_event_handler_high_priority

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::ContestationSubmittedService.new.call(payload: payload)
    end
  end
end
