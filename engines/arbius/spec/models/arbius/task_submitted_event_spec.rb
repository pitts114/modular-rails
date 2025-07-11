require 'rails_helper'

RSpec.describe Arbius::TaskSubmittedEvent, type: :model do
  let(:event_detail) { create(:arbius_ethereum_event_detail) }
  subject { described_class.new(arbius_ethereum_event_details_id: event_detail.id, task_id: 'task1', model: 'modelA', fee: 100, sender: '0xabc') }

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

  it 'is invalid without model' do
    subject.model = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without fee' do
    subject.fee = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without sender' do
    subject.sender = nil
    expect(subject).not_to be_valid
  end
end
