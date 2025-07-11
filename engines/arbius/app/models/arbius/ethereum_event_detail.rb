module Arbius
  class EthereumEventDetail < ApplicationRecord
    # belongs_to :ethereum_event, class_name: 'Arbius::EthereumEvent', foreign_key: :ethereum_event_id, inverse_of: :details

    has_one :task_submitted, class_name: 'Arbius::TaskSubmittedEvent', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :arbius_ethereum_event_details, dependent: :nullify
    has_one :solution_submitted, class_name: 'Arbius::SolutionSubmittedEvent', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :arbius_ethereum_event_details, dependent: :nullify
    has_one :contestation_submitted, class_name: 'Arbius::ContestationSubmittedEvent', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :arbius_ethereum_event_details, dependent: :nullify
    has_one :contestation_vote, class_name: 'Arbius::ContestationVoteEvent', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :arbius_ethereum_event_details, dependent: :nullify

    validates :ethereum_event_id, presence: true
    validates :block_hash, presence: true
    validates :block_number, presence: true, numericality: { only_integer: true }
    validates :chain_id, presence: true, numericality: { only_integer: true }
    validates :contract_address, presence: true
    validates :transaction_hash, presence: true
    validates :transaction_index, presence: true, numericality: { only_integer: true }
  end
end
