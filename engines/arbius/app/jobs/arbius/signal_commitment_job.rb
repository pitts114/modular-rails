require 'json'

module Arbius
  class SignalCommitmentJob < ApplicationJob
    queue_as :arbius_event_handler

    def perform(payload)
      payload = JSON.parse(payload, symbolize_names: true)
      Arbius::CommitmentSignaledService.new.call(payload:)
    end
  end
end
