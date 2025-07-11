# frozen_string_literal: true

module Arbius
  class OldEventCleanupService
    EVENT_MODELS = [
      Arbius::TaskSubmittedEvent,
      Arbius::SignalCommitmentEvent,
      Arbius::SolutionSubmittedEvent,
      Arbius::SolutionClaimedEvent,
      Arbius::ContestationSubmittedEvent,
      Arbius::ContestationVoteEvent,
      Arbius::ContestationVoteFinishEvent
    ]

    def self.call(older_than: 2.weeks.ago)
      EVENT_MODELS.each do |model|
        model.where('created_at < ?', older_than).delete_all
      end
    end
  end
end
