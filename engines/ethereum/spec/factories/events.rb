# frozen_string_literal: true

FactoryBot.define do
  factory :ethereum_event, class: 'Ethereum::Event' do
    address { "0x#{SecureRandom.hex(20)}" }
    block_hash { SecureRandom.hex(32) }
    block_number { 1 }  # You may want to randomize or sequence
    transaction_hash { SecureRandom.hex(32) }
    transaction_index { 0 }
    log_index { 0 }
    removed { false }
    data { "0x" }
    chain_id { 1 }
    finalized { false }
    raw_event { { foo: 'bar' } }

    transient do
      event_topics_count { 2 }
    end

    after(:create) do |event, evaluator|
      if evaluator.event_topics_count
        evaluator.event_topics_count.times do |i|
          create(:ethereum_event_topic, ethereum_event: event, topic_index: i)
        end
      end
    end
  end
end
