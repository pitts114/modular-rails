# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Event, type: :model do
  subject(:event) { described_class.new }

  describe 'associations' do
    it 'has many ethereum_event_topics and destroys them on delete' do
      association = described_class.reflect_on_association(:ethereum_event_topics)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'is invalid without a block_number' do
      event.block_number = nil
      expect(event).not_to be_valid
      expect(event.errors[:block_number]).to be_present
    end

    it 'is invalid without a log_index' do
      event.log_index = nil
      expect(event).not_to be_valid
      expect(event.errors[:log_index]).to be_present
    end

    it 'is invalid without a transaction_hash' do
      event.transaction_hash = nil
      expect(event).not_to be_valid
      expect(event.errors[:transaction_hash]).to be_present
    end

    it 'is invalid without an address' do
      event.address = nil
      expect(event).not_to be_valid
      expect(event.errors[:address]).to be_present
    end

    it 'is invalid without a chain_id' do
      event.chain_id = nil
      expect(event).not_to be_valid
      expect(event.errors[:chain_id]).to be_present
    end
  end

  describe 'database columns' do
    it 'has a block_number column of type integer' do
      column = described_class.columns_hash['block_number']
      expect(column).not_to be_nil
      expect(column.type).to eq(:integer)
    end

    it 'has a log_index column of type integer' do
      column = described_class.columns_hash['log_index']
      expect(column).not_to be_nil
      expect(column.type).to eq(:integer)
    end

    it 'has a transaction_hash column of type string' do
      column = described_class.columns_hash['transaction_hash']
      expect(column).not_to be_nil
      expect(column.type).to eq(:string)
    end

    it 'has an address column of type string' do
      column = described_class.columns_hash['address']
      expect(column).not_to be_nil
      expect(column.type).to eq(:string)
    end

    it 'has a data column of type string' do
      column = described_class.columns_hash['data']
      expect(column).not_to be_nil
      expect(column.type).to eq(:string)
    end

    it 'has a chain_id column of type integer' do
      column = described_class.columns_hash['chain_id']
      expect(column).not_to be_nil
      expect(column.type).to eq(:integer)
    end

    it 'has a removed column of type boolean' do
      column = described_class.columns_hash['removed']
      expect(column).not_to be_nil
      expect(column.type).to eq(:boolean)
    end

    it 'has a finalized column of type boolean' do
      column = described_class.columns_hash['finalized']
      expect(column).not_to be_nil
      expect(column.type).to eq(:boolean)
    end
  end
end
