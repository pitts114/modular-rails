# frozen_string_literal: true

module Ethereum
  class OldCoreCleanupJob < ApplicationJob
    queue_as :default

    def perform
      Ethereum::OldCoreCleanupService.call
    end
  end
end
