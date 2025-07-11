# frozen_string_literal: true

require 'eth'

module Ethereum
  class TransactionBroadcastService
    class Error < StandardError; end
    class BroadcastError < StandardError; end
    class TimeoutError < StandardError; end

    DEFAULT_TIMEOUT = 60 # seconds
    DEFAULT_POLL_INTERVAL = 1 # seconds

    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    # wait: whether to wait for mining (default: true)
    # timeout: max seconds to wait (default: DEFAULT_TIMEOUT)
    # poll_interval: seconds between mining checks (default: DEFAULT_POLL_INTERVAL)
    def send_transaction(signed_tx:, wait: true, timeout: DEFAULT_TIMEOUT, poll_interval: DEFAULT_POLL_INTERVAL)
      raw_tx = signed_tx.respond_to?(:hex) ? signed_tx.hex : signed_tx.to_s
      result = @eth_client.eth_send_raw_transaction(raw_tx)
      tx_hash = result && result["result"]
      raise BroadcastError, "Failed to broadcast transaction: #{result && result["error"] ? result["error"] : result.inspect}" unless tx_hash

      if wait
        start_time = Time.now
        loop do
          break if @eth_client.tx_mined?(tx_hash)
          if Time.now - start_time > timeout
            raise TimeoutError, "Transaction broadcasted but not mined within #{timeout} seconds"
          end
          sleep poll_interval
        end
      end
      tx_hash
    end
  end
end
