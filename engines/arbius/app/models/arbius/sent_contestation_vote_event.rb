module Arbius
  class SentContestationVoteEvent < Arbius::ApplicationRecord
    before_save :checksummize_address

    STATUSES = %w[pending confirmed failed].freeze

    validates :address, presence: true
    validates :task, presence: true
    validates :yea, inclusion: { in: [ true, false ] }
    validates :status, inclusion: { in: STATUSES }

    private

    def checksummize_address
      self.address = Eth::Address.new(address).checksummed if address.present?
    end
  end
end
