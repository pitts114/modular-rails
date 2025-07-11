# frozen_string_literal: true

FactoryBot.define do
  factory :task_submitted_event, class: 'Arbius::TaskSubmittedEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    task_id { SecureRandom.uuid }
    model { 'test-model' }
    fee { 1.23 }
    sender { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    created_at { Time.current }
  end

  factory :signal_commitment_event, class: 'Arbius::SignalCommitmentEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    address { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    commitment { '0xdeadbeef' }
    created_at { Time.current }
  end

  factory :solution_submitted_event, class: 'Arbius::SolutionSubmittedEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    address { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    task { 'task-1' }
    created_at { Time.current }
  end

  factory :solution_claimed_event, class: 'Arbius::SolutionClaimedEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    address { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    task { 'task-1' }
    created_at { Time.current }
  end

  factory :contestation_submitted_event, class: 'Arbius::ContestationSubmittedEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    address { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    task { 'task-1' }
    created_at { Time.current }
  end

  factory :contestation_vote_event, class: 'Arbius::ContestationVoteEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    address { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    task { 'task-1' }
    yea { true }
    created_at { Time.current }
  end

  factory :contestation_vote_finish_event, class: 'Arbius::ContestationVoteFinishEvent' do
    association :arbius_ethereum_event_details, factory: :arbius_ethereum_event_detail
    task_id { SecureRandom.uuid }
    start_idx { 0 }
    end_idx { 1 }
    created_at { Time.current }
  end
end
