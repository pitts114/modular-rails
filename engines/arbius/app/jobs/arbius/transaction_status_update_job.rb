require 'json'

module Arbius
  class TransactionStatusUpdateJob < ApplicationJob
    queue_as :arbius_event_handler_high_priority

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::TransactionStatusUpdateService.new.call(payload:)
    end
  end
end
