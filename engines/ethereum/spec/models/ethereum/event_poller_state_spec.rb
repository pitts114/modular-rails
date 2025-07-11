require 'rails_helper'

RSpec.describe Ethereum::EventPollerState, type: :model do
  subject { described_class.new(poller_name: 'arbius_event_poller', last_processed_block: 12345) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a poller_name' do
    subject.poller_name = nil
    expect(subject).not_to be_valid
  end

  it 'is not valid without a last_processed_block' do
    subject.last_processed_block = nil
    expect(subject).not_to be_valid
  end

  it 'is not valid with a negative last_processed_block' do
    subject.last_processed_block = -1
    expect(subject).not_to be_valid
  end

  it 'is not valid with a non-integer last_processed_block' do
    subject.last_processed_block = 'abc'
    expect(subject).not_to be_valid
  end

  it 'is not valid with a duplicate poller_name' do
    described_class.create!(poller_name: 'arbius_event_poller', last_processed_block: 100)
    duplicate = described_class.new(poller_name: 'arbius_event_poller', last_processed_block: 200)
    expect(duplicate).not_to be_valid
  end
end
