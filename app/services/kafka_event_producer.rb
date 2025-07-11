# frozen_string_literal: true

# Service for producing events to Kafka
class KafkaEventProducer
  def initialize(kafka_client:)
    @kafka = kafka_client
  end

  def publish(topic:, payload:)
    @kafka.deliver_message(payload.to_json, topic: topic)
  end
end
