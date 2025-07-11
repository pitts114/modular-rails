module Arbius
  class ContestationVoteTotalsService
    class ContestationNotFoundError < StandardError; end

    def initialize(
      contestation_submitted_model: Arbius::ContestationSubmitted,
      contestation_vote_model: Arbius::ContestationVote
      )
    end

    def call(task_id:)
      begin
        contestation_submitted = @contestation_submitted_model.find_by(task_id: task_id)
        raise ContestationNotFoundError, "Contestation not found for task_id: #{task_id}" unless contestation_submitted

        votes = @contestation_vote_model.where(contestation_submitted_id: contestation_submitted.id)

        total_votes = votes.count
        total_yea_votes = votes.where(vote: true).count
        total_nay_votes = votes.where(vote: false).count

        {
          total_votes: total_votes,
          total_yea_votes: total_yea_votes,
          total_nay_votes: total_nay_votes
        }
      end
    end
  end
end
