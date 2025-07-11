# frozen_string_literal: true

module Arbius
  class OldEventCleanupJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::OldEventCleanupService.call
    end
  end
end
