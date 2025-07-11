module Arbius
  class SolutionSubmittedEvent < Arbius::ApplicationRecord
    before_save :checksummize_address

    belongs_to :arbius_ethereum_event_details, class_name: 'Arbius::EthereumEventDetail', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :solution_submitted
    belongs_to :arbius_miner, class_name: 'Arbius::Miner', foreign_key: :address, primary_key: :address, inverse_of: :solution_submitted_events, optional: true

    validates :arbius_ethereum_event_details_id, presence: true
    validates :address, presence: true
    validates :task, presence: true

    private

    def checksummize_address
      self.address = Eth::Address.new(address).checksummed if address.present?
    end
  end
end
