module Arbius
  class ContestationVoteFinishEvent < Arbius::ApplicationRecord
    belongs_to :arbius_ethereum_event_details, class_name: 'Arbius::EthereumEventDetail', foreign_key: :arbius_ethereum_event_details_id

    validates :arbius_ethereum_event_details_id, presence: true
    validates :task_id, presence: true
    validates :start_idx, presence: true
    validates :end_idx, presence: true
  end
end
