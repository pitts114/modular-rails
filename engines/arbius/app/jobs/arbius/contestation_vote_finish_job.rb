require 'json'

module Arbius
  class ContestationVoteFinishJob < ApplicationJob
    queue_as :arbius_event_handler

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::ContestationVoteFinishService.new.call(payload: payload)
    end
  end
end
