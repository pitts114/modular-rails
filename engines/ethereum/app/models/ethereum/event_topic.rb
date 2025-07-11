class Ethereum::EventTopic < Ethereum::ApplicationRecord
  belongs_to :ethereum_event, class_name: 'Ethereum::Event', foreign_key: :ethereum_event_id

  validates :topic_index, :topic, presence: true
end
