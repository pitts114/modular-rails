# frozen_string_literal: true

require Rails.root.join("engines/ethereum/lib/ethereum/event_poller")
require Rails.root.join("lib/eth_event_utils")

module Ethereum
  class TestEventPollService
    ENGINE_EVENT_NAMES = %w[TaskSubmitted SignalCommitment SolutionSubmitted SolutionClaimed ContestationSubmitted ContestationVote ContestationVoteFinish ValidatorDeposit].freeze

    def initialize(
      logger: Rails.logger,
      poller_name: "event_poller",
      poll_interval: 3,
      batch_size: 1_000,
      engine_contract: Eth::Contract.from_abi(
        name: "Engine",
        address: ENV.fetch("ENGINE_CONTRACT_ADDRESS"),
        abi: JSON.parse(File.read(Rails.root.join("engines/ethereum/abi/engine.json")))
      ),
      default_start_block:,
      client: Ethereum::ClientProvider.client,
      event_handler_job: Ethereum::EventHandlerJob,
      eth_event_utils: EthEventUtils,
      event_poller_class: Ethereum::EventPoller,
      poll_limit: 10
    )
      @logger = logger
      @poller_name = poller_name
      @poll_interval = poll_interval
      @batch_size = batch_size
      @engine_contract = engine_contract
      @default_start_block = default_start_block
      @client = client
      @event_handler_job = event_handler_job
      @eth_event_utils = eth_event_utils
      @event_poller_class = event_poller_class
      @poll_limit = poll_limit
    end

    def call
      event_name_to_topic0 = {
        @engine_contract => ENGINE_EVENT_NAMES.map { |name| [ name, @eth_event_utils.topic0_for(event_name: name, abi: @engine_contract.abi) ] }.to_h
      }
      poller = @event_poller_class.new(
        client: @client,
        contracts: [ @engine_contract ],
        event_name_to_topic0: event_name_to_topic0,
        start_block:  @default_start_block,
        poll_interval: @poll_interval,
        chain_id: @client.chain_id,
        batch_size: @batch_size,
        logger: @logger
      )
      @logger.info "Starting Arbius event poller..."

      poll_count = 0
      while true
        poller.poll_once do |type, value|
          case type
          when :log
            @event_handler_job.perform_later(value.to_json, @client.chain_id)
          end
        end
        yield if block_given?
        poll_count += 1
        if poll_count >= @poll_limit
          raise "TestEventPollService poll limit (#{@poll_limit}) reached"
        end
        sleep(@poll_interval)
      end
    end
  end
end
