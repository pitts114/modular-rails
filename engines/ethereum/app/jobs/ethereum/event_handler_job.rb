# frozen_string_literal: true

module Ethereum
  class EventHandlerJob < ApplicationJob
    queue_as :ethereum_event_handler

    def perform(log_json, chain_id)
      raw_event = JSON.parse(log_json)
      log = LogEventDto.new(raw_event)
      Ethereum::EventHandler.new.call(log:, chain_id:, raw_event:)
    end
  end
end
