require 'rails_helper'

RSpec.describe Arbius::MinerContestationVoteCheck, type: :model do
  subject { described_class.new(task_id: 'task-1') }

  it 'is valid with a unique task_id' do
    expect(subject).to be_valid
  end

  it 'is invalid without a task_id' do
    subject.task_id = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:task_id]).to include("can't be blank")
  end

  it 'is invalid with a duplicate task_id' do
    described_class.create!(task_id: 'task-1')
    duplicate = described_class.new(task_id: 'task-1')
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:task_id]).to include('has already been taken')
  end
end
