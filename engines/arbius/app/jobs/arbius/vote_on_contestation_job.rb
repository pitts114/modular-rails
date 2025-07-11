module Arbius
  class VoteOnContestationJob < ApplicationJob
    queue_as :arbius_vote_on_contestation

    def perform(task_id, from, yea)
      Arbius::VoteOnContestationService.new.call(task_id:, from:, yea:)
    end
  end
end
