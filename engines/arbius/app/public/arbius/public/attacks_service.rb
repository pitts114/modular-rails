module Arbius
  module Public
    class AttacksService
      def initialize(
        attack_solution_model: Arbius::AttackSolution,
        miner_model: Arbius::Miner,
        solution_submitted_event_model: Arbius::SolutionSubmittedEvent,
        contestation_vote_finish_event_model: Arbius::ContestationVoteFinishEvent,
        contestation_vote_repository: Arbius::ContestationVoteRepository,
        contestation_submitted_event_model: nil
      )
        @attack_solution_model = attack_solution_model
        @miner_model = miner_model
        @solution_submitted_event_model = solution_submitted_event_model
        @contestation_vote_finish_event_model = contestation_vote_finish_event_model
        @contestation_vote_repository = contestation_vote_repository
        @contestation_submitted_event_model = contestation_submitted_event_model || Arbius::ContestationSubmittedEvent
      end

      def attacks(limit: nil, offset: nil)
        query = @attack_solution_model.order(created_at: :desc)
        query = query.limit(limit) if limit
        query = query.offset(offset) if offset

        query.map do |attack_solution|
          votes = @contestation_vote_repository.votes_for_task(task_id: attack_solution.task)
          total_yea_votes = votes.count { |_, yea| yea }
          total_nay_votes = votes.count { |_, yea| !yea }
          solution_submitted_event = @solution_submitted_event_model.find_by(task: attack_solution.task)
          contestation_vote_finish_event = @contestation_vote_finish_event_model.find_by(task_id: attack_solution.task)
          {
            task_id: attack_solution.task,
            attack_solution_id: attack_solution.id,
            miner: solution_submitted_event&.address,
            solution_submitted: @solution_submitted_event_model.exists?(task: attack_solution.task),
            solution_submitted_event_id: solution_submitted_event&.id,
            solution_submitted_transaction_hash: solution_submitted_event&.arbius_ethereum_event_details&.transaction_hash,
            contestation_vote_finished: contestation_vote_finish_event.present?,
            contestation_vote_finish_event_id: contestation_vote_finish_event&.id,
            contestation_vote_finish_transaction_hash: contestation_vote_finish_event&.arbius_ethereum_event_details&.transaction_hash,
            total_yea_votes: total_yea_votes,
            total_nay_votes: total_nay_votes,
            created_at: attack_solution.created_at
          }
        end
      end

      def attack(attack_solution_id:)
        attack_solution = @attack_solution_model.find_by(id: attack_solution_id)
        return nil unless attack_solution

        solution_submitted_event = @solution_submitted_event_model.find_by(task: attack_solution.task)
        contestation_vote_finish_event = @contestation_vote_finish_event_model.find_by(task_id: attack_solution.task)
        contestation_submitted_event = @contestation_submitted_event_model.find_by(task: attack_solution.task)
        votes = @contestation_vote_repository.votes_for_task(task_id: attack_solution.task)
        total_yea_votes = votes.count { |_, yea| yea }
        total_nay_votes = votes.count { |_, yea| !yea }

        {
          task_id: attack_solution.task,
          attack_solution_id: attack_solution.id,
          miner: solution_submitted_event&.address,
          solution_submitted: solution_submitted_event.present?,
          solution_submitted_event_id: solution_submitted_event&.id,
          solution_submitted_transaction_hash: solution_submitted_event&.arbius_ethereum_event_details&.transaction_hash,
          contestation_vote_finished: contestation_vote_finish_event.present?,
          contestation_vote_finish_event_id: contestation_vote_finish_event&.id,
          contestation_vote_finish_transaction_hash: contestation_vote_finish_event&.arbius_ethereum_event_details&.transaction_hash,
          contestation_submitted_transaction_hash: contestation_submitted_event&.arbius_ethereum_event_details&.transaction_hash,
          total_yea_votes: total_yea_votes,
          total_nay_votes: total_nay_votes,
          created_at: attack_solution.created_at
        }
      end
    end
  end
end
