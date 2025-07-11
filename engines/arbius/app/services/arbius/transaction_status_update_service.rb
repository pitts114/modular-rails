# frozen_string_literal: true

module Arbius
  class TransactionStatusUpdateService
    def initialize(
      sent_contestation_vote_model: Arbius::SentContestationVoteEvent,
      logger: Rails.logger,
      defend_solution_job: Arbius::DefendSolutionJob
    )
      @sent_contestation_vote_model = sent_contestation_vote_model
      @logger = logger
      @defend_solution_job = defend_solution_job
    end

    def call(payload:)
      context = payload.with_indifferent_access[:context]

      return unless [ 'Arbius::VoteOnContestationService', 'Arbius::SubmitContestationService' ].include? context&.with_indifferent_access&.dig(:class)

      task_id = context.with_indifferent_access[:task_id]

      from_address = payload.with_indifferent_access[:from]
      status = payload.with_indifferent_access[:status]

      # Find the matching SentContestationVoteEvent
      sent_vote = @sent_contestation_vote_model.find_by(
        address: from_address,
        task: task_id
      ) if task_id

      if sent_vote
        case status
        when 'confirmed'
          sent_vote.update!(status: 'confirmed')
          @logger.info("[TransactionStatusHandler] Updated contestation vote status to confirmed for address: #{from_address}, task: #{task_id}")
        when 'failed'
          sent_vote.update!(status: 'failed')
          @defend_solution_job.perform_later(task_id)
          @logger.info("[TransactionStatusHandler] Updated contestation vote status to failed for address: #{from_address}, task: #{task_id}")
        end
      elsif task_id
        @logger.warn("[TransactionStatusHandler] Could not find SentContestationVoteEvent for address: #{from_address}, task: #{task_id}")
      end
    end
  end
end
