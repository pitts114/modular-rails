require_relative "./boot"
require_relative "./environment"
require "dotenv/load"
require "clockwork"

module Clockwork
  every(1.minute, "arbius.check_miner_contestation_vote") do
    Arbius::CheckMinerContestationVoteJob.perform_later
  end

  every(5.seconds, "ethereum.event_finalizer") do
    Ethereum::EventFinalizerJob.perform_later
  end

  every(1.minute, "arbius.claim_uncontested_solutions") do
    Arbius::FinishContestationVotesJob.perform_later
  end

  # miner will claim uncontested solutions itself. only run this if we're bogus mining.
  every(1.minute, "arbius.claim_uncontested_solutions") do
    Arbius::BulkClaimUncontestedSolutionsJob.perform_later
  end if ENV.fetch("ENABLE_CLAIM_UNCONTESTED_SOLUTIONS_JOB", "false") == "true"

  every(1.hour, "arbius.old_event_cleanup") do
    Arbius::OldEventCleanupJob.perform_later
  end

  every(1.hour, "ethereum.old_core_cleanup") do
    Ethereum::OldCoreCleanupJob.perform_later
  end

  every(1.hour, "arbius.validator_balance_check") do
    Arbius::ValidatorBalanceCheckJob.perform_later
  end

  every(1.minute, "arbius.wai_bulk_bogus_auto_mine_scheduler") do
    Arbius::WaiBulkBogusAutoMineSchedulerJob.perform_later
  end

  # add schedule for enqueueing transaction jobs (in case we somehow miss transactions)
end
