module Ethereum
  module Public
    class LatestBlockNumberService
      def initialize(model: Ethereum::EventPollerState)
        @model = model
      end

      def call
        @model.find_by(poller_name: 'event_poller')&.last_processed_block || 0
      end
    end
  end
end
