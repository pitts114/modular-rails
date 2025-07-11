# frozen_string_literal: true

FactoryBot.define do
  factory :ethereum_transaction, class: 'Ethereum::Transaction' do
    from { '0xab5801a7d398351b8be11c439e05c5b3259aec9b' }
    to { '0x0000000000000000000000000000000000000000' }
    value { 1 }
    chain_id { 1 }
    status { 'pending' }
    tx_hash { SecureRandom.hex(32) }
    created_at { Time.current }
  end
end
