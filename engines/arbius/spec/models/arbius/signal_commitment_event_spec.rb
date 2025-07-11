require 'rails_helper'

RSpec.describe Arbius::SignalCommitmentEvent, type: :model do
  let(:event_detail) { create(:arbius_ethereum_event_detail) }
  subject { described_class.new(arbius_ethereum_event_details_id: event_detail.id, address: '0xabc', commitment: 'commitment1') }

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

  it 'is invalid without commitment' do
    subject.commitment = nil
    expect(subject).not_to be_valid
  end
end
