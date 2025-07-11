# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Transaction, type: :model do
  subject do
    described_class.new(
      from: '0xabc123',
      to: '0xdef456',
      value: 1000000000000000000,
      chain_id: 1,
      status: 'pending',
      data: '0xdeadbeef'
    )
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is valid with nil data' do
    subject.data = nil
    expect(subject).to be_valid
  end

  it 'is invalid without a from' do
    subject.from = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without a to' do
    subject.to = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without a value' do
    subject.value = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without a chain_id' do
    subject.chain_id = nil
    expect(subject).not_to be_valid
  end

  it 'is invalid without a status' do
    subject.status = nil
    expect(subject).not_to be_valid
  end

  it 'enforces unique tx_hash' do
    described_class.create!(from: '0xabc123', to: '0xdef456', value: 1, chain_id: 1, status: 'pending', tx_hash: '0xhash')
    tx2 = described_class.new(from: '0xabc123', to: '0xdef456', value: 2, chain_id: 1, status: 'pending', tx_hash: '0xhash')
    expect(tx2).not_to be_valid
  end
end
