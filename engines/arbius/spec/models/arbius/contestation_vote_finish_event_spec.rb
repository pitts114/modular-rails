require 'rails_helper'

RSpec.describe Arbius::ContestationVoteFinishEvent, type: :model do
  let!(:event_detail) { create(:arbius_ethereum_event_detail) }
  subject { described_class.new(arbius_ethereum_event_details_id: event_detail.id, task_id: 'task1', start_idx: 1, end_idx: 2) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without arbius_ethereum_event_details_id' do
    subject.arbius_ethereum_event_details_id = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without task_id' do
    subject.task_id = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without start_idx' do
    subject.start_idx = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without end_idx' do
    subject.end_idx = nil
    expect(subject).not_to be_valid
  end
end
