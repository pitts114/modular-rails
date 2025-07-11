require 'rails_helper'

RSpec.describe Arbius::SentContestationVoteEvent, type: :model do
  subject { described_class.new(address: '0xabc', task: 'task1', yea: true) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without address' do
    subject.address = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without task' do
    subject.task = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without yea' do
    subject.yea = nil
    expect(subject).not_to be_valid
  end

  it 'coerces non-boolean yea to boolean and is valid' do
    subject.yea = 'yes'
    expect(subject).to be_valid
    expect(subject.yea).to eq true
  end

  it 'has a default status of pending' do
    expect(subject.status).to eq 'pending'
  end

  it 'validates status is one of the allowed values' do
    %w[pending confirmed failed].each do |status|
      subject.status = status
      expect(subject).to be_valid
    end

    subject.status = 'invalid'
    expect(subject).not_to be_valid
  end
end
