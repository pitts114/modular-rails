# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::EventTopic, type: :model do
  subject(:topic) { described_class.new }

  describe 'associations' do
    it 'belongs to ethereum_event' do
      association = described_class.reflect_on_association(:ethereum_event)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it 'is invalid without a topic_index' do
      topic.topic_index = nil
      expect(topic).not_to be_valid
      expect(topic.errors[:topic_index]).to be_present
    end

    it 'is invalid without a topic' do
      topic.topic = nil
      expect(topic).not_to be_valid
      expect(topic.errors[:topic]).to be_present
    end
  end

  describe 'database columns' do
    it 'has an event_id column of type uuid' do
      column = described_class.columns_hash['ethereum_event_id']
      expect(column).not_to be_nil
      expect(column.type).to eq(:uuid)
    end

    it 'has a topic_index column of type integer' do
      column = described_class.columns_hash['topic_index']
      expect(column).not_to be_nil
      expect(column.type).to eq(:integer)
    end

    it 'has a topic column of type string' do
      column = described_class.columns_hash['topic']
      expect(column).not_to be_nil
      expect(column.type).to eq(:string)
    end
  end
end
