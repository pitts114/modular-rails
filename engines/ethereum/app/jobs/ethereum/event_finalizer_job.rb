# frozen_string_literal: true

module Ethereum
  class EventFinalizerJob < ApplicationJob
    queue_as :ethereum_event_finalizer

    def perform
      Ethereum::EventFinalizerService.new.call
    end
  end
end
