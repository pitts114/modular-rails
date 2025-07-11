module Ethereum
  class EventPollerState < Ethereum::ApplicationRecord
    validates :poller_name, presence: true, uniqueness: true
    validates :last_processed_block, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end
