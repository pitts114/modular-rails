# frozen_string_literal: true

module Arbius
  class WaiBulkBogusAutoMineSchedulerJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::WaiBulkBogusAutoMineSchedulerService.new.call
    end
  end
end
