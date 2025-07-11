require 'rails_helper'

RSpec.describe Arbius::EthereumEventDetail, type: :model do
  subject { build(:arbius_ethereum_event_detail) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without ethereum_event_id' do
    subject.ethereum_event_id = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without block_hash' do
    subject.block_hash = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without block_number' do
    subject.block_number = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without chain_id' do
    subject.chain_id = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without contract_address' do
    subject.contract_address = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without transaction_hash' do
    subject.transaction_hash = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without transaction_index' do
    subject.transaction_index = nil
    expect(subject).not_to be_valid
  end
end
