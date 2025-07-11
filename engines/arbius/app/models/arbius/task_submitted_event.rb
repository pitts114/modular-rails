module Arbius
  class TaskSubmittedEvent < Arbius::ApplicationRecord
    belongs_to :arbius_ethereum_event_details, class_name: 'Arbius::EthereumEventDetail', foreign_key: :arbius_ethereum_event_details_id, inverse_of: :task_submitted

    validates :arbius_ethereum_event_details_id, presence: true
    validates :task_id, presence: true
    validates :model, presence: true
    validates :fee, presence: true, numericality: true
    validates :sender, presence: true
  end
end
