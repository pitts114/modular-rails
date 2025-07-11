# frozen_string_literal: true

module Ethereum
  class Transaction < ApplicationRecord
    self.table_name = 'ethereum_transactions'

    STATUSES = %w[pending broadcasted confirmed failed].freeze

    validates :from, :to, :value, :chain_id, :status, presence: true
    validates :tx_hash, uniqueness: true, allow_nil: true
    validates :status, inclusion: { in: STATUSES }
  end
end
