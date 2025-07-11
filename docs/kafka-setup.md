# Kafka + Karafka Setup

## 1. Start Kafka and Zookeeper

```
docker-compose up -d kafka zookeeper
```

## 2. Install dependencies

```
bundle install
```

## 3. Karafka setup

- Karafka config: `karafka.rb`
- Consumer example: `app/consumers/example_consumer.rb`
- Producer example: `app/services/kafka_event_producer.rb`
- Kafka config: `config/kafka.yml`

## 4. Producing an event

```
kafka = Kafka.new(["localhost:9092"], client_id: "rails_kafka_demo")
producer = KafkaEventProducer.new(kafka_client: kafka)
producer.publish(topic: "rails_kafka_demo_example", payload: { foo: "bar" })
```

## 5. Consuming events

```
bundle exec karafka server
```

## 6. Where to add event handling logic

- See `app/consumers/example_consumer.rb` for where to process incoming events.

---

For more, see the [Karafka documentation](https://karafka.io/docs/).
