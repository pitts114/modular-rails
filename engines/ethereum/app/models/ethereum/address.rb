class Ethereum::Address < Ethereum::ApplicationRecord
  before_save :checksummize_address

  validates :address, presence: true, uniqueness: true

  private

  def checksummize_address
    self.address = Eth::Address.new(address).checksummed if address.present?
  end
end
