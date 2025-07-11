class Ethereum::Event < Ethereum::ApplicationRecord
  before_save :checksummize_address

  has_many :ethereum_event_topics, class_name: 'Ethereum::EventTopic', dependent: :destroy, foreign_key: :ethereum_event_id

  validates :address, :block_hash, :block_number, :transaction_hash, :transaction_index, :log_index, :data, :chain_id, presence: true
  validates :removed, :finalized, inclusion: { in: [ true, false ] }
  validates :raw_event, presence: true

  private

  def checksummize_address
    self.address = Eth::Address.new(address).checksummed if address.present?
  end
end
