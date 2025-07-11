# frozen_string_literal: true

# Example consumer that prints messages payloads
class ExampleConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.info("Consumed message: ")
      Rails.logger.info(message.payload)
      # Add your event handling logic here
    end
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
