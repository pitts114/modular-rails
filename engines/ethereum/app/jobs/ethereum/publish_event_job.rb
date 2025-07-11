# frozen_string_literal: true

module Ethereum
  class PublishEventJob < ApplicationJob
    queue_as :ethereum_event_publisher

    def perform(ethereum_event_id)
      Ethereum::PublishEventService.new.call(ethereum_event_id:)
    end
  end
end
