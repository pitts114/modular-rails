require 'json'

module Arbius
  class ValidatorDepositJob < ApplicationJob
    queue_as :arbius_event_handler

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::ValidatorDepositService.new.call(payload:)
    end
  end
end
