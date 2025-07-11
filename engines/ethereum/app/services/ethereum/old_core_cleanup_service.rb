# frozen_string_literal: true

module Ethereum
  class OldCoreCleanupService
    MODELS = [
      Ethereum::Event,
      Ethereum::Transaction
    ]

    def self.call(older_than: 2.weeks.ago)
      # Delete dependent event topics before deleting events
      Ethereum::Event.where('created_at < ?', older_than).find_each do |event|
        event.ethereum_event_topics.delete_all
      end
      MODELS.each do |model|
        model.where('created_at < ?', older_than).delete_all
      end
    end
  end
end
