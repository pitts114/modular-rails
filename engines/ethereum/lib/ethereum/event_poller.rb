require 'eth'
require 'json'
require 'logger'

module Ethereum
  class EventPoller
    attr_reader :last_processed_block

    def initialize(
      client:,
      contracts: [],
      event_name_to_topic0: {},
      poll_interval: 10,
      start_block: 0,
      chain_id: nil,
      batch_size: 10_000,
      logger: Logger.new(File::NULL)
    )
      @client = client
      @contracts = contracts
      @event_name_to_topic0 = event_name_to_topic0
      @poll_interval = poll_interval
      @chain_id = chain_id
      @last_processed_block = start_block
      @batch_size = batch_size
      @logger = logger
    end

    def run
      @logger.info("Starting Ethereum event poller...")
      @running = true
      @shutdown_requested = false
      trap_signals
      while @running
        poll_once do |type, value|
          yield type, value if block_given?
        end
        sleep(@poll_interval) if @running
      end
      @logger.info("Stopping Ethereum event poller...") if @shutdown_requested
      @logger.info("Ethereum event poller stopped.")
    end

    def stop
      @running = false
      @shutdown_requested = true
    end

    def poll_once
      latest_block = with_eth_client_retry { @client.eth_block_number }['result'].to_i(16)
      from_block = @last_processed_block
      to_block = [ from_block + @batch_size - 1, latest_block ].min
      return if from_block > to_block

      # Collect all contract addresses and all topic0s
      addresses = @contracts.map(&:address)
      topic0s = @event_name_to_topic0.values.flat_map(&:values).uniq

      response = with_eth_client_retry do
        @client.eth_get_logs(
          address: addresses,
          fromBlock: "0x#{from_block.to_s(16)}",
          toBlock: "0x#{to_block.to_s(16)}",
          topics: [ topic0s ]
        )
      end
      # @logger.info(response.inspect)
      unless response.is_a?(Hash) && response['result'].is_a?(Array)
        raise "eth_get_logs did not return a result array: #{response.inspect}"
      end
      logs = response['result']

      logs.each do |log|
        yield :log, log if block_given?
      end
      yield :last_processed_block, to_block if block_given?
      @last_processed_block = to_block + 1
    end

    private

    def trap_signals
      return if @signals_trapped
      [ 'INT', 'TERM' ].each do |sig|
        Signal.trap(sig) do
          @running = false
          @shutdown_requested = true
        end
      end
      @signals_trapped = true
    end

    def with_eth_client_retry
      loop do
        response = yield
        if response.is_a?(Hash) && response["code"] == -32005
          @logger.warn("Rate limited by Ethereum client, retrying after delay...")
          sleep(@poll_interval)
          next
        end
        return response
      end
    end
  end
end
