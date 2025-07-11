module Arbius
  class SentContestationVoteRepository
    class NotUniqueError < StandardError; end

    def initialize(sent_contestation_vote_model: Arbius::SentContestationVoteEvent)
      @sent_contestation_vote_model = sent_contestation_vote_model
    end

    # Inserts multiple nay votes for the given task and addresses
    # @param task [String, Integer] the task id
    # @param addresses [Array<String>] the addresses to insert votes for
    def insert_votes!(task:, addresses:, yea:)
      @sent_contestation_vote_model.insert_all!(
        addresses.map do |address|
          { address: address, task:, yea:, status: 'pending' }
        end
      )
    rescue ActiveRecord::RecordNotUnique => e
      raise NotUniqueError, "Failed to insert nay votes for task #{task}: #{e.message}"
    end
  end
end
