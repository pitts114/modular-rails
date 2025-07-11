require 'rails_helper'

RSpec.describe Arbius::ContestationVoteEvent, type: :model do
  let(:event_detail) { create(:arbius_ethereum_event_detail) }
  subject { described_class.new(arbius_ethereum_event_details_id: event_detail.id, address: '0xabc', task: 'task1', yea: true) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without arbius_ethereum_event_details_id' do
    subject.arbius_ethereum_event_details_id = nil
    expect(subject).not_to be_valid
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
end
