# frozen_string_literal: true

FactoryBot.define do
  factory :arbius_miner, class: 'Arbius::Miner' do
    address { '0xabc123def4567890abc123def4567890abc123de' }
  end
end
