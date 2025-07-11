module Arbius
  class CheckMinerContestationVoteJob < ApplicationJob
    queue_as :arbius_check_miner_contestation_vote

    def perform
      Arbius::CheckMinerContestationVoteService.new.call
    end
  end
end
