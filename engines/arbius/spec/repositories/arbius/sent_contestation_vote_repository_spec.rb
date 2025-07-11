require 'rails_helper'

RSpec.describe Arbius::SentContestationVoteRepository do
  let(:sent_contestation_vote_model) { double(:sent_contestation_vote_model) }
  let(:repository) { described_class.new(sent_contestation_vote_model: sent_contestation_vote_model) }
  let(:task_id) { 'task-1' }
  let(:addresses) { [ '0xA', '0xB' ] }

  describe '#insert_votes!' do
    it 'calls insert_all! with nay votes for each address' do
      expected_args = [
        { address: '0xA', task: task_id, yea: false, status: 'pending' },
        { address: '0xB', task: task_id, yea: false, status: 'pending' }
      ]
      expect(sent_contestation_vote_model).to receive(:insert_all!).with(expected_args)
      repository.insert_votes!(task: task_id, addresses: addresses, yea: false)
    end

    it 'raises if insert_all! raises' do
      allow(sent_contestation_vote_model).to receive(:insert_all!).and_raise(ActiveRecord::RecordNotUnique)
      expect {
        repository.insert_votes!(task: task_id, addresses: addresses, yea: false)
      }.to raise_error(Arbius::SentContestationVoteRepository::NotUniqueError)
    end
  end
end
