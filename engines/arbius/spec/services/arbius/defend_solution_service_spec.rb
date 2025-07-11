require 'rails_helper'

RSpec.describe Arbius::DefendSolutionService do
  let(:contestation_vote_repository) { double(:contestation_vote_repository) }
  let(:miner_model) { double(:miner_model) }
  let(:validator_repository) { double(:validator_repository) }
  let(:sent_contestation_vote_repository) { double(:sent_contestation_vote_repository) }
  let(:vote_on_contestation_job) { double(:vote_on_contestation_job) }
  let(:miner_contestation_vote_check_model) { double(:miner_contestation_vote_check_model) }
  let(:random) { double(:random) }
  let(:contestation_submitted_event_model) { double(:contestation_submitted_event_model) }
  let(:solution_submitted_event_model) { double(:solution_submitted_event_model) }
  let(:address_shuffle_service) { double(:address_shuffle_service) }
  let(:alert_outnumbered_service) { double(:alert_outnumbered_service) }
  let(:feature_flag) { double(:flipper) }
  let(:shutdown_service) { double(:shutdown_service) }

  let(:service) do
    described_class.new(
      contestation_vote_repository: contestation_vote_repository,
      miner_model: miner_model,
      validator_repository: validator_repository,
      sent_contestation_vote_repository: sent_contestation_vote_repository,
      vote_on_contestation_job: vote_on_contestation_job,
      miner_contestation_vote_check_model: miner_contestation_vote_check_model,
      random: random,
      contestation_submitted_event_model: contestation_submitted_event_model,
      solution_submitted_event_model: solution_submitted_event_model,
      address_shuffle_service: address_shuffle_service,
      alert_outnumbered_job: alert_outnumbered_service,
      feature_flag: feature_flag,
      shutdown_service: shutdown_service
    )
  end

  let(:task_id) { 'task-1' }
  let(:miner_address) { '0xMiner' }
  let(:validator_addresses) { [ '0xVal1', '0xVal2', '0xVal3' ] }
  let(:arbius_contestation_submitted_event) { double(:contestation_submitted_event, task: task_id) }
  let(:arbius_solution_submitted_event) { double(:solution_submitted_event, task: task_id, address: miner_address) }
  let(:arbius_miner) { double(:miner, address: miner_address) }

  before do
    # No need to stub_const Flipper, use feature_flag double
  end

  describe '#call' do
    context 'when contestation event is missing' do
      it 'logs and returns nil' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(nil)
        expect(Rails.logger).to receive(:info).with("[DefendSolutionService] No contestation found for task #{task_id} in DefendSolutionService")
        expect(service.call(task_id: task_id)).to be_nil
      end
    end

    context 'when solution submitted event is missing' do
      it 'raises SolutionSubmittedEventNotFoundError' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(nil)
        expect {
          service.call(task_id: task_id)
        }.to raise_error(Arbius::DefendSolutionService::SolutionSubmittedEventNotFoundError)
      end
    end

    context 'when miner is missing' do
      it 'returns nil' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_solution_submitted_event)
        allow(miner_model).to receive(:find_by).with(address: miner_address).and_return(nil)
        expect(service.call(task_id: task_id)).to be_nil
      end
    end

    context 'when the feature flag is disabled' do
      it 'returns early and logs' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(false)
        expect(Rails.logger).to receive(:info).with("[DefendSolutionService] 'defend solution' feature flag is disabled for task #{task_id}")
        expect(service.call(task_id: task_id)).to be_nil
      end
    end

    context 'when there are not enough validators to defend' do
      it 'raises OutnumberedError, calls shutdown_service, and enqueues the alert job' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_solution_submitted_event)
        allow(miner_model).to receive(:find_by).with(address: miner_address).and_return(arbius_miner)
        allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return([ [ miner_address, true ], [ '0xVal1', true ] ])
        allow(miner_contestation_vote_check_model).to receive(:exists?).with(task_id: task_id).and_return(false)
        allow(validator_repository).to receive(:find_addresses_excluding).and_return([])
        allow(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: [ '0xVal1', miner_address ]).and_return([])
        alert_outnumbered_job = double(:alert_outnumbered_job)
        service.instance_variable_set(:@alert_outnumbered_job, alert_outnumbered_job)
        expect(alert_outnumbered_job).to receive(:perform_later)
        expect(shutdown_service).to receive(:call)
        expect {
          service.call(task_id: task_id)
        }.to raise_error(Arbius::DefendSolutionService::OutnumberedError)
      end
    end

    context 'when the automatic miner vote is assumed' do
      it 'adds an extra nay vote and calculates correctly' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_solution_submitted_event)
        allow(miner_model).to receive(:find_by).with(address: miner_address).and_return(arbius_miner)
        # Two nay votes, but automatic miner vote will be assumed, so total_nay_votes = 3
        # Three yea votes, so total_yea_votes = 3, total_nay_votes = 2 + 1 (auto) = 3
        # To ensure the code proceeds, make total_yea_votes > total_nay_votes
        votes = [ [ miner_address, true ], [ '0xVal1', true ], [ '0xVal2', true ], [ '0xVal3', false ] ]
        allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return(votes)
        allow(miner_contestation_vote_check_model).to receive(:exists?).with(task_id: task_id).and_return(false)
        # Exclusion list should include all nay voters and the miner
        expect(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: [ '0xVal3', miner_address ]).and_return([ '0xVal4', '0xVal5' ])
        allow(address_shuffle_service).to receive(:shuffle).with(addresses: [ '0xVal4', '0xVal5' ], task_id: task_id).and_return([ '0xVal4', '0xVal5' ])
        allow(sent_contestation_vote_repository).to receive(:insert_votes!)
        allow(vote_on_contestation_job).to receive(:perform_later)
        service.call(task_id: task_id)
      end
    end

    context 'when there are enough validators to defend' do
      it 'inserts votes and enqueues jobs with correct exclusion list' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_solution_submitted_event)
        allow(miner_model).to receive(:find_by).with(address: miner_address).and_return(arbius_miner)
        votes = [ [ miner_address, true ], [ '0xVal1', true ], [ '0xVal2', true ], [ '0xVal3', false ] ]
        allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return(votes)
        allow(miner_contestation_vote_check_model).to receive(:exists?).with(task_id: task_id).and_return(false)
        # Exclusion list should include all nay voters and the miner
        expect(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: [ '0xVal3', miner_address ]).and_return([ '0xVal4', '0xVal5' ])
        allow(address_shuffle_service).to receive(:shuffle).with(addresses: [ '0xVal4', '0xVal5' ], task_id: task_id).and_return([ '0xVal4', '0xVal5' ])
        insert_votes_args = nil
        allow(sent_contestation_vote_repository).to receive(:insert_votes!) { |args| insert_votes_args = args; nil }
        allow(vote_on_contestation_job).to receive(:perform_later)
        service.call(task_id: task_id)
        expect(insert_votes_args).not_to be_nil
        expect(insert_votes_args[:addresses]).to include('0xVal4')
        expect(insert_votes_args[:yea]).to eq(false)
        expect(vote_on_contestation_job).to have_received(:perform_later).with(task_id, '0xVal4', false)
      end
    end

    context 'when insert_votes! raises NotUniqueError' do
      it 'returns nil' do
        allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true)
        allow(contestation_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_contestation_submitted_event)
        allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(arbius_solution_submitted_event)
        allow(miner_model).to receive(:find_by).with(address: miner_address).and_return(arbius_miner)
        votes = [ [ miner_address, true ], [ '0xVal1', true ], [ '0xVal2', false ] ]
        allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return(votes)
        allow(miner_contestation_vote_check_model).to receive(:exists?).with(task_id: task_id).and_return(false)
        allow(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: [ '0xVal2', miner_address ]).and_return([ '0xVal3', '0xVal4' ])
        allow(address_shuffle_service).to receive(:shuffle).with(addresses: [ '0xVal3', '0xVal4' ], task_id: task_id).and_return([ '0xVal3', '0xVal4' ])
        allow(sent_contestation_vote_repository).to receive(:insert_votes!).and_raise(Arbius::SentContestationVoteRepository::NotUniqueError)
        expect(service.call(task_id: task_id)).to be_nil
      end
    end

    context 'when the feature flag is enabled' do
      before { allow(feature_flag).to receive(:enabled?).with(:defend_solution).and_return(true) }
      # ...existing tests for this context...
    end
  end
end
