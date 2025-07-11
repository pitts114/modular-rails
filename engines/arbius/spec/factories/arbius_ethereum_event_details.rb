# frozen_string_literal: true

FactoryBot.define do
  factory :arbius_ethereum_event_detail, class: 'Arbius::EthereumEventDetail' do
    ethereum_event_id { SecureRandom.uuid }
    block_hash { '0xabc' }
    block_number { 1 }
    chain_id { 1 }
    contract_address { '0xdef' }
    transaction_hash { '0x123' }
    transaction_index { 0 }
  end
end
