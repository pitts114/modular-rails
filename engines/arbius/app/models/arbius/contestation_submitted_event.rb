module Arbius
  class ContestationSubmittedEvent < Arbius::ApplicationRecord
    before_save :checksummize_address

    belongs_to :arbius_ethereum_event_details, class_name: 'Arbius::EthereumEventDetail', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :contestation_submitted

    validates :arbius_ethereum_event_details_id, presence: true
    validates :address, presence: true
    validates :task, presence: true

    private

    def checksummize_address
      self.address = Eth::Address.new(address).checksummed if address.present?
    end
  end
end
