require 'rails_helper'

RSpec.describe Arbius::CheckMinerContestationVoteService do
  let(:repo) { double(:miner_contestation_vote_check_repository) }
  let(:job) { double(:defend_solution_job) }
  let(:service) { described_class.new(miner_contestation_vote_check_repository: repo, defend_solution_job: job) }

  describe '#call' do
    it 'calls update_checks! and enqueues DefendSolutionJob for each task_id' do
      expect(repo).to receive(:update_checks!).and_return([ 'task1', 'task2' ])
      expect(job).to receive(:perform_later).with('task1')
      expect(job).to receive(:perform_later).with('task2')
      service.call
    end

    it 'does nothing if update_checks! returns empty array' do
      expect(repo).to receive(:update_checks!).and_return([])
      expect(job).not_to receive(:perform_later)
      service.call
    end
  end
end
