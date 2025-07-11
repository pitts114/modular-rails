module Arbius
  module Public
    class SolutionsService
      def initialize(
        solution_submitted_event_model: Arbius::SolutionSubmittedEvent,
        miner_model: Arbius::Miner,
        contestation_submitted_event_model: Arbius::ContestationSubmittedEvent,
        contestation_vote_model: Arbius::ContestationVoteEvent,
        contestation_vote_repository: Arbius::ContestationVoteRepository,
        contestation_vote_finish_event_model: Arbius::ContestationVoteFinishEvent,
        solution_claimed_event_model: Arbius::SolutionClaimedEvent
      )
        @solution_submitted_event_model = solution_submitted_event_model
        @miner_model = miner_model
        @contestation_submitted_event_model = contestation_submitted_event_model
        @contestation_vote_model = contestation_vote_model
        @contestation_vote_repository = contestation_vote_repository
        @contestation_vote_finish_event_model = contestation_vote_finish_event_model
        @solution_claimed_event_model = solution_claimed_event_model
      end

      def solutions(limit: nil, offset: nil)
        query = @solution_submitted_event_model.joins(:arbius_miner).order(created_at: :desc)
        query = query.limit(limit) if limit
        query = query.offset(offset) if offset

        query.map do |solution_submitted_event|
          contestation_submitted_event = @contestation_submitted_event_model.find_by(task: solution_submitted_event.task)
          votes = @contestation_vote_repository.votes_for_task(task_id: solution_submitted_event.task)
          total_yea_votes = votes.count { |_, yea| yea }
          total_nay_votes = votes.count { |_, yea| !yea }
          {
            task_id: solution_submitted_event.task,
            contestation_submitted: contestation_submitted_event.present?,
            solution_claimed: @solution_claimed_event_model.exists?(task: solution_submitted_event.task),
            contestation_vote_finished: @contestation_vote_finish_event_model.exists?(task_id: solution_submitted_event.task),
            solution_submitted_event_id: solution_submitted_event.id,
            miner: solution_submitted_event.arbius_miner.address,
            total_yea_votes: total_yea_votes,
            total_nay_votes: total_nay_votes
          }
        end
      end

      def solution(solution_submitted_event_id:)
        solution_submitted_event = @solution_submitted_event_model.find_by(id: solution_submitted_event_id)
        return nil unless solution_submitted_event

        contestation_submitted_event = @contestation_submitted_event_model.find_by(task: solution_submitted_event.task)
        yea_vote_events = @contestation_vote_model.where(task: solution_submitted_event.task, yea: true)
        nay_vote_events = @contestation_vote_model.where(task: solution_submitted_event.task, yea: false)

        {
          task_id: solution_submitted_event.task,
          transaction_hash: solution_submitted_event.arbius_ethereum_event_details.transaction_hash,
          miner: solution_submitted_event.arbius_miner.address,
          contestation_submitted: contestation_submitted_event.present?,
          solution_claimed: @solution_claimed_event_model.exists?(task: solution_submitted_event.task),
          contestation_vote_finished: @contestation_vote_finish_event_model.exists?(task_id: solution_submitted_event.task),
          contestation_submitted_validator: contestation_submitted_event&.address,
          contestation_submitted_transaction_hash: contestation_submitted_event&.arbius_ethereum_event_details&.transaction_hash,
          contestation_yea_votes: yea_vote_events.map { |vote| { address: vote.address, transaction_hash: vote&.arbius_ethereum_event_details&.transaction_hash } },
          contestation_nay_votes: nay_vote_events.map { |vote| { address: vote.address, transaction_hash: vote&.arbius_ethereum_event_details&.transaction_hash } }
        }
      end
    end
  end
end
