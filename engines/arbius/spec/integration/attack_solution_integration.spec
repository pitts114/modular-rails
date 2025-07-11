require 'rails_helper'
require Rails.root.join('engines/ethereum/spec/support/test_event_poll_service')

RSpec.describe 'Attack Solution Integration', type: :integration do
  let(:wallet1) { '0xb532a213B0d1fBC21D49EA44973E13351Bd1609e' } # miner
  let(:wallet2) { '0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69' } # hostile
  let(:wallet3) { '0xC1E75C292c75A71E2F1449950C07203F0f09ADE7' } # hostile
  let(:wallet4) { '0x4C13157dA14b79910801F7C79D960BE8bc9689b9' } # validator
  let(:wallet5) { '0xD4392F2F4E3aD7B000124a4Cd824350167985938' } # validator
  let(:wallet6) { '0x6d21f977F9752eBD252972632b7D5CE133D028B3' } # hostile
  let(:model) { '0x7cd06b3facb05c072fb359904a7381e8f28218f410830f85018f3922621ed33a' }
  let(:fee) { 1_000_000_000_000_000 } # 0.001 in wei
  let(:input) { { "prompt": "abc123" } }

  before do
    unless ENV['RUN_ATTACK_INTEGRATION'] == 'true'
      skip 'Attack integration tests are skipped unless RUN_ATTACK_INTEGRATION=true'
    end

    Resque.queues.each { |queue| Resque.remove_queue(queue) }

    Flipper.enable(:attack_solution)

    [ wallet4, wallet5 ].each do |address|
      Arbius::Validator.create!(address:)
    end
    Arbius::Miner.create!(address: wallet1)
  end

  def perform_all_resque_jobs
    loop do
      job_found = false
      Ethereum::EventFinalizerJob.perform_now
      Resque.queues.each do |queue|
        if (job = Resque.reserve(queue))
          job.perform
          job_found = true
        end
      end
      break unless job_found
    end
  end

  it 'runs a full attack flow with multiple wallets' do
    # 1. Wallet 2 submits a task, commitment, and solution
    # task_id = Arbius::BogusAutoMineService.new.call(from: wallet1, model: model, fee: fee, input: input)
    # expect(task_id).to be_present
    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::SubmitTaskService.new.submit_task(from: wallet2, version: 0, owner: wallet2, model:, fee:, input:)
    perform_all_resque_jobs

    task_id = nil
    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      perform_all_resque_jobs
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        tx_hash = result[:tx_hash]
        task_submitted_event = Arbius::TaskSubmittedEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: tx_hash }).first
        next unless task_submitted_event.present?
        task_id = task_submitted_event.task_id
        break
      end
    end

    sleep 2

    cid = '0x' + SecureRandom.hex(32)
    commitment = Arbius::GenerateCommitmentService.new.generate_commitment_onchain(sender: wallet2, taskid: task_id, cid:)
    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::SignalCommitmentService.new.call(from: wallet2, commitment: commitment)
    perform_all_resque_jobs

    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      perform_all_resque_jobs
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        signal_commitment_event = Arbius::SignalCommitmentEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: result[:tx_hash] }).first
        next unless signal_commitment_event.present?
        break
      end
    end

    sleep 2

    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::SubmitSolutionService.new.call(from: wallet2, cid:, taskid: task_id)
    perform_all_resque_jobs

    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      perform_all_resque_jobs
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        tx_hash = result[:tx_hash]
        solution_submitted_event = Arbius::SolutionSubmittedEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: tx_hash }).first
        next unless solution_submitted_event.present?
        break
      end
    end

    # task_id = Arbius::TaskSubmittedEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: tx_hash }).first.task_id

    # 2. Wallet 1 submits a contestation on the solution, votes should be 1-1
    # Wallet 4 or 5 will vote to attack the solution, so votes should be 2-1
    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::MarkSolutionForAttackService.new.call(task_id: task_id)
    perform_all_resque_jobs

    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      perform_all_resque_jobs
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        contestation_submitted_event = Arbius::ContestationSubmittedEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: result[:tx_hash] }).first
        break if contestation_submitted_event.present?
      end
    end

    perform_all_resque_jobs

    # check votes before and after the check miner contestation vote job runs after the initial contestation submission
    votes = Arbius::ContestationVoteRepository.votes_for_task(task_id:)
    total_yea_votes = votes.count { |_, yea| yea }
    total_nay_votes = votes.count { |_, yea| !yea }
    expect(total_yea_votes).to eq(2) # Wallet 1's vote and wallet 4 or 5's vote
    expect(total_nay_votes).to eq(1) # Wallet 2's automatic vote (the miner)

    Arbius::CheckMinerContestationVoteJob.perform_later
    perform_all_resque_jobs

    votes = Arbius::ContestationVoteRepository.votes_for_task(task_id:)
    total_yea_votes = votes.count { |_, yea| yea }
    total_nay_votes = votes.count { |_, yea| !yea }
    expect(total_yea_votes).to eq(2) # Wallet 1's vote and wallet 4 or 5's vote
    expect(total_nay_votes).to eq(1) # Wallet 2's real vote (the miner)

    sleep 2

    # 3. Wallet 3 votes on the contestation (yea = true means contestation is valid, i.e., solution is bad)
    # Either wallet 4 or 5 will vote to attack the solution, so votes should be 3-2
    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::VoteOnContestationService.new.call(from: wallet3, task_id: task_id, yea: false)

    perform_all_resque_jobs

    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      perform_all_resque_jobs
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        contestation_vote_event = Arbius::ContestationVoteEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: result[:tx_hash] }).first
        break if contestation_vote_event.present?
      end
    end

    votes = Arbius::ContestationVoteRepository.votes_for_task(task_id:)
    total_yea_votes = votes.count { |_, yea| yea }
    total_nay_votes = votes.count { |_, yea| !yea }
    expect(total_yea_votes).to eq(3) # Contestation submitter (wallet 1) and wallet 3 and 4's votes
    expect(total_nay_votes).to eq(2) # Miner and one defender's votes

    sleep 2

    block_number = Ethereum::LatestBlockNumberService.new.call
    ethereum_transaction_id = Arbius::VoteOnContestationService.new.call(from: wallet6, task_id: task_id, yea: false)

    perform_all_resque_jobs

    Ethereum::TestEventPollService.new(default_start_block: block_number).call do
      begin
        perform_all_resque_jobs
      rescue Arbius::AttackSolutionService::OutnumberedError
        perform_all_resque_jobs
      end
      result = Ethereum::Public::TransactionStatusService.new.call(ethereum_transaction_id: ethereum_transaction_id)
      if result[:status] == 'confirmed'
        contestation_vote_event = Arbius::ContestationVoteEvent.joins(:arbius_ethereum_event_details).where(arbius_ethereum_event_details: { transaction_hash: result[:tx_hash] }).first
        break if contestation_vote_event.present?
      end
    end

    votes = Arbius::ContestationVoteRepository.votes_for_task(task_id:)
    total_yea_votes = votes.count { |_, yea| yea }
    total_nay_votes = votes.count { |_, yea| !yea }
    expect(total_yea_votes).to eq(3) # Contestation submitter and two yea voters
    expect(total_nay_votes).to eq(3) # Miner and two defender's votes

    # we're not outnumbered, shut it all down!
    expect(Flipper.enabled?(:defend_solution)).to be false
    expect(Flipper.enabled?(:bulk_bogus_auto_mine)).to be false
    expect(Flipper.enabled?(:attack_solution)).to be false

    # tests transaction status update integration
    expect(Arbius::SentContestationVoteEvent.all.map(&:status)).to all(eq('confirmed'))
  end
end
