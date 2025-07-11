module Arbius
  class Miner < Arbius::ApplicationRecord
    before_save :checksummize_address

    has_many :solution_submitted_events, class_name: 'Arbius::SolutionSubmittedEvent', foreign_key: :address, primary_key: :address, inverse_of: :arbius_miner
    validates :address, presence: true

    private

    def checksummize_address
      self.address = Eth::Address.new(address).checksummed if address.present?
    end
  end
end
