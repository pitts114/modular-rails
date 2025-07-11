module Arbius
  class FinishContestationVotesJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::FinishContestationVotesService.new.call
    end
  end
end
