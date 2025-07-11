# frozen_string_literal: true

require Rails.root.join("engines/ethereum/lib/ethereum/event_poller")
require Rails.root.join("lib/eth_event_utils")

module Ethereum
  class EventPollerService
    ENGINE_EVENT_NAMES = %w[TaskSubmitted SignalCommitment SolutionSubmitted SolutionClaimed ContestationSubmitted ContestationVote ContestationVoteFinish ValidatorDeposit].freeze

    def initialize(
      logger: Rails.logger,
      poller_name: "event_poller",
      poll_interval: ENV.fetch("ETHEREUM_EVENT_POLL_INTERVAL").to_i,
      batch_size: ENV.fetch("ETHEREUM_EVENT_POLL_BATCH_SIZE", 10_000).to_i,
      engine_contract: Eth::Contract.from_abi(
        name: "Engine",
        address: ENV.fetch("ENGINE_CONTRACT_ADDRESS"),
        abi: JSON.parse(File.read(Rails.root.join("engines/ethereum/abi/engine.json")))
      ),
      event_poller_state_model: Ethereum::EventPollerState,
      default_start_block: ENV.fetch("ETHEREUM_EVENT_START_BLOCK").to_i,
      client: Ethereum::ClientProvider.client,
      event_handler_job: Ethereum::EventHandlerJob,
      eth_event_utils: EthEventUtils,
      event_poller_class: Ethereum::EventPoller
    )
      @logger = logger
      @poller_name = poller_name
      @poll_interval = poll_interval
      @batch_size = batch_size
      @engine_contract = engine_contract
      @event_poller_state_model = event_poller_state_model
      @default_start_block = default_start_block
      @client = client
      @event_handler_job = event_handler_job
      @eth_event_utils = eth_event_utils
      @event_poller_class = event_poller_class
    end

    def call
      event_name_to_topic0 = {
        @engine_contract => ENGINE_EVENT_NAMES.map { |name| [ name, @eth_event_utils.topic0_for(event_name: name, abi: @engine_contract.abi) ] }.to_h
      }
      poller = @event_poller_class.new(
        client: @client,
        contracts: [ @engine_contract ],
        event_name_to_topic0: event_name_to_topic0,
        start_block: @event_poller_state_model.find_by(poller_name: @poller_name)&.last_processed_block || @default_start_block,
        poll_interval: @poll_interval,
        chain_id: @client.chain_id,
        batch_size: @batch_size,
        logger: @logger
      )
      @logger.info "Starting Arbius event poller..."
      poller.run do |type, value|
        case type
        when :log
          @event_handler_job.perform_later(value.to_json, @client.chain_id)
        when :last_processed_block
          state = @event_poller_state_model.find_or_initialize_by(poller_name: @poller_name)
          if state.last_processed_block != value
            state.last_processed_block = value
            state.save!
          end
          @logger.info "Processed up to block: #{value}"
        end
      end
    end
  end
end
