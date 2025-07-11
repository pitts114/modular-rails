module Arbius
  class Validator < Arbius::ApplicationRecord
    before_save :checksummize_address

    validates :address, presence: true

    private

    def checksummize_address
      self.address = Eth::Address.new(address).checksummed if address.present?
    end
  end
end
