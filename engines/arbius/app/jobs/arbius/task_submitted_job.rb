require 'json'

module Arbius
  class TaskSubmittedJob < ApplicationJob
    queue_as :arbius_event_handler

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::TaskSubmittedService.new.call(payload:)
    end
  end
end
