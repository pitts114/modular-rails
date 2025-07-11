module Ethereum
  class EventFinalizerService
    def initialize(
      client: Ethereum::ClientProvider.client,
      event_repository: Ethereum::EventRepository,
      latest_block_number_service: Ethereum::LatestBlockNumberService.new,
      publish_event_service: Ethereum::PublishEventService.new,
      publish_event_job: Ethereum::PublishEventJob
    )
      @client = client
      @event_repository = event_repository
      @latest_block_number_service = latest_block_number_service
      @publish_event_service = publish_event_service
      @publish_event_job = publish_event_job
    end

    def call
      ethereum_event_ids = @event_repository.finalize_older_than(
        chain_id: @client.chain_id,
        block_number: latest_finalized_block_number
      )

      ethereum_event_ids.each do |ethereum_event_id|
        @publish_event_job.perform_later(ethereum_event_id)
      end
    end

    private

    def latest_finalized_block_number
      # we'll consider all events to be finalized for now.
      @latest_block_number_service.call + 1
    end
  end
end
