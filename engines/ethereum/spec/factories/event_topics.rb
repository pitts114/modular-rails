# frozen_string_literal: true

FactoryBot.define do
  factory :ethereum_event_topic, class: 'Ethereum::EventTopic' do
    sequence(:topic_index) { |n| n }
    topic { SecureRandom.hex(32) }
  end
end
