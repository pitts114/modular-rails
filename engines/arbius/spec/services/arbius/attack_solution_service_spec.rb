# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::AttackSolutionService do
  let(:feature_flag) { double(:feature_flag, enabled?: true) }
  let(:attack_solution_model) { double(:attack_solution_model) }
  let(:solution_submitted_event_model) { double(:solution_submitted_event_model) }
  let(:contestation_vote_repository) { double(:contestation_vote_repository) }
  let(:miner_model) { double(:miner_model) }
  let(:validator_repository) { double(:validator_repository) }
  let(:sent_contestation_vote_repository) { double(:sent_contestation_vote_repository) }
  let(:vote_on_contestation_job) { double(:vote_on_contestation_vote_job) }
  let(:miner_contestation_vote_check_model) { double(:miner_contestation_vote_check_model) }
  let(:random) { double(:random) }
  let(:address_shuffle_service) { double(:address_shuffle_service) }
  let(:alert_outnumbered_job) { double(:alert_outnumbered_job) }
  let(:shutdown_service) { double(:shutdown_service) }
  let(:validator_model) { double(:validator_model) }
  let(:service) do
    described_class.new(
      contestation_vote_repository: contestation_vote_repository,
      miner_model: miner_model,
      validator_repository: validator_repository,
      sent_contestation_vote_repository: sent_contestation_vote_repository,
      vote_on_contestation_job: vote_on_contestation_job,
      miner_contestation_vote_check_model: miner_contestation_vote_check_model,
      random: random,
      attack_solution_model: attack_solution_model,
      solution_submitted_event_model: solution_submitted_event_model,
      address_shuffle_service: address_shuffle_service,
      alert_outnumbered_job: alert_outnumbered_job,
      feature_flag: feature_flag,
      shutdown_service: shutdown_service,
      validator_model: validator_model
    )
  end
  let(:task_id) { 1 }
  let(:event) { double(:solution_submitted_event, task: task_id, address: '0xabc') }
  let(:attack_solution) { double(:attack_solution) }

  before do
    allow(Rails.logger).to receive(:info)
  end

  context 'when feature flag is disabled' do
    before { allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(false) }
    it 'returns early and logs info' do
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect(sent_contestation_vote_repository).not_to receive(:insert_votes!)
      expect(Rails.logger).to receive(:info).with(/feature flag is disabled/)
      expect(service.call(task_id: task_id)).to be_nil
    end
  end

  context 'when no attack solution exists' do
    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(nil)
    end
    it 'raises AttackSolutionNotFoundError' do
      expect(sent_contestation_vote_repository).not_to receive(:insert_votes!)
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect {
        service.call(task_id: task_id)
      }.to raise_error(described_class::AttackSolutionNotFoundError)
    end
  end

  context 'when no solution submitted event exists' do
    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(attack_solution)
      allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(nil)
    end
    it 'raises SolutionSubmittedEventNotFoundError' do
      expect(sent_contestation_vote_repository).not_to receive(:insert_votes!)
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect {
        service.call(task_id: task_id)
      }.to raise_error(described_class::SolutionSubmittedEventNotFoundError)
    end
  end

  context 'when the solution was submitted by our own miner or validator' do
    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(attack_solution)
      allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(event)
      allow(miner_model).to receive(:find_by).with(address: event.address).and_return(double(:miner))
      allow(validator_model).to receive(:find_by).with(address: event.address).and_return(nil)
    end
    it 'returns early' do
      expect(sent_contestation_vote_repository).not_to receive(:insert_votes!)
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect(service.call(task_id: task_id)).to be_nil
    end
  end

  context 'when not enough validators to attack' do
    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(attack_solution)
      allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(event)
      allow(miner_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(validator_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return([ [ '0x1', false ], [ '0x2', false ], [ '0x3', true ] ])
      allow(service).to receive(:assume_automatic_miner_vote?).and_return(false)
      allow(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: instance_of(Array)).and_return([])
      allow(alert_outnumbered_job).to receive(:perform_later)
      allow(shutdown_service).to receive(:call)
    end
    it 'alerts, disables feature, and raises OutnumberedError' do
      expect(sent_contestation_vote_repository).not_to receive(:insert_votes!)
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect(alert_outnumbered_job).to receive(:perform_later)
      expect(shutdown_service).to receive(:call)
      expect {
        service.call(task_id: task_id)
      }.to raise_error(described_class::OutnumberedError)
    end
  end

  context 'when attack proceeds and votes are inserted' do
    let(:votes) { [ [ '0x1', false ], [ '0x2', false ], [ '0x3', true ] ] }
    let(:nay_voters) { [ '0x1', '0x2' ] }
    let(:validators) { [ '0x4', '0x5', '0x6' ] }
    let(:shuffled_validators) { [ '0x5', '0x4', '0x6' ] }
    let(:voters) { [ '0x5', '0x4' ] }

    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(attack_solution)
      allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(event)
      allow(miner_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(validator_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return(votes)
      allow(service).to receive(:assume_automatic_miner_vote?).and_return(false)
      allow(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: instance_of(Array)).and_return(validators)
      allow(address_shuffle_service).to receive(:shuffle).with(addresses: validators, task_id: task_id).and_return(shuffled_validators)
      allow(sent_contestation_vote_repository).to receive(:insert_votes!).with(task: task_id, addresses: voters, yea: true)
      allow(vote_on_contestation_job).to receive(:perform_later)
    end

    it 'inserts votes and enqueues jobs' do
      expect(sent_contestation_vote_repository).to receive(:insert_votes!).with(task: task_id, addresses: voters, yea: true)
      voters.each do |address|
        expect(vote_on_contestation_job).to receive(:perform_later).with(task_id, address, true)
      end
      service.call(task_id: task_id)
    end
  end

  context 'when insert_votes! raises NotUniqueError' do
    before do
      allow(feature_flag).to receive(:enabled?).with(:attack_solution).and_return(true)
      allow(attack_solution_model).to receive(:find_by).with(task: task_id).and_return(attack_solution)
      allow(solution_submitted_event_model).to receive(:find_by).with(task: task_id).and_return(event)
      allow(miner_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(validator_model).to receive(:find_by).with(address: event.address).and_return(nil)
      allow(contestation_vote_repository).to receive(:votes_for_task).with(task_id: task_id).and_return([ [ '0x1', false ], [ '0x2', false ], [ '0x3', true ] ])
      allow(service).to receive(:assume_automatic_miner_vote?).and_return(false)
      allow(validator_repository).to receive(:find_addresses_excluding).with(exclude_addresses: instance_of(Array)).and_return([ '0x4', '0x5' ])
      allow(address_shuffle_service).to receive(:shuffle).and_return([ '0x4', '0x5' ])
      allow(sent_contestation_vote_repository).to receive(:insert_votes!).and_raise(Arbius::SentContestationVoteRepository::NotUniqueError)
    end
    it 'returns early if NotUniqueError is raised' do
      expect(sent_contestation_vote_repository).to receive(:insert_votes!)
      expect(vote_on_contestation_job).not_to receive(:perform_later)
      expect(service.call(task_id: task_id)).to be_nil
    end
  end
end
