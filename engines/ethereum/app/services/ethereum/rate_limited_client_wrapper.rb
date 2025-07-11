# frozen_string_literal: true

require 'redis'

module Ethereum
  # Rate-limiting wrapper around Eth::Client to prevent hitting Infura rate limits
  # Uses Redis for cross-process coordination and transparent method forwarding
  class RateLimitedClientWrapper
    # Default rate limit: 3 calls per second
    DEFAULT_RATE_LIMIT = 3.0
    DEFAULT_WINDOW_SIZE = 1.0 # 1 second window

    # Utility to convert camelCase RPC method names to snake_case (as eth.rb does)
    def self.camel_to_snake(str)
      str.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end

    # Credit costs for different RPC methods (based on Infura pricing)
    # https://docs.metamask.io/services/get-started/pricing/credit-cost/
    CREDIT_COSTS = {
      'eth_accounts' => 80,
      'eth_blobBaseFee' => 300,
      'eth_blockNumber' => 80,
      'eth_call' => 80,
      'eth_chainId' => 5,
      'eth_createAccessList' => 80,
      'eth_estimateGas' => 300,
      'eth_feeHistory' => 80,
      'eth_gasPrice' => 80,
      'eth_getBalance' => 80,
      'eth_getBlockByHash' => 80,
      'eth_getBlockByNumber' => 80,
      'eth_getBlockReceipts' => 1000,
      'eth_getBlockTransactionCountByHash' => 150,
      'eth_getBlockTransactionCountByNumber' => 150,
      'eth_getCode' => 80,
      'eth_getLogs' => 255,
      'eth_getProof' => 150,
      'eth_getStorageAt' => 80,
      'eth_getTransactionByBlockHashAndIndex' => 150,
      'eth_getTransactionByBlockNumberAndIndex' => 150,
      'eth_getTransactionByHash' => 80,
      'eth_getTransactionCount' => 80,
      'eth_getTransactionReceipt' => 80,
      'eth_getUncleByBlockHashAndIndex' => 150,
      'eth_getUncleByBlockNumberAndIndex' => 150,
      'eth_getUncleCountByBlockHash' => 150,
      'eth_getUncleCountByBlockNumber' => 150,
      'eth_getWork' => 80,
      'eth_hashrate' => 5,
      'eth_maxPriorityFeePerGas' => 80,
      'eth_mining' => 5,
      'eth_protocolVersion' => 5,
      'eth_sendRawTransaction' => 80,
      'eth_sign' => 80,
      'eth_simulateV1' => 300,
      'eth_submitWork' => 80,
      'eth_subscribe' => 5,
      'eth_syncing' => 5,
      'eth_unsubscribe' => 10,
      'net_listening' => 5,
      'net_peerCount' => 80,
      'net_version' => 5,
      'web3_clientVersion' => 80
    }.each_with_object({}) { |(k, v), h| h[self.camel_to_snake(k)] = v }.freeze
    DEFAULT_CREDIT_COST = 80

    class RateLimitedError < StandardError; end

    def initialize(
      client,
      rate_limit: DEFAULT_RATE_LIMIT,
      window_size: DEFAULT_WINDOW_SIZE,
      redis: nil,
      use_credits: false,
      credit_limit: 500,
      time: Time,
      kernel: Kernel,
      logger: Rails.logger
    )
      @client = client
      @rate_limit = rate_limit.to_f
      @window_size = window_size.to_f
      @redis = redis || Redis.new(url: ENV.fetch('REDIS_URL'), password: ENV.fetch('REDIS_PASSWORD', nil))
      @use_credits = use_credits
      @credit_limit = credit_limit.to_f
      @redis_key = @use_credits ? 'ethereum:credit_limiter' : 'ethereum:rate_limiter'
      @time = time
      @kernel = kernel
      @logger = logger
    end

    # Forward all method calls to the wrapped client after rate limiting
    def method_missing(method, *args, **kwargs, &block)
      if @client.respond_to?(method)
        if @use_credits
          wait_for_credit_limit(method)
        else
          wait_for_rate_limit
        end
        response = @client.send(method, *args, **kwargs, &block)
        if response.is_a?(Hash) && response["code"] == -32005
          raise RateLimitedError, "Received rate limit error from upstream (code -32005) for method: #{method}"
        end
        response
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @client.respond_to?(method, include_private) || super
    end

    private

    def wait_for_rate_limit
      loop do
        current_time = @time.now.to_f

        # Use Redis pipeline for atomic operations
        allowed = @redis.pipelined do |pipe|
          # Remove old timestamps outside the window
          pipe.zremrangebyscore(@redis_key, '-inf', current_time - @window_size)

          # Count current requests in the window
          pipe.zcard(@redis_key)
        end

        current_count = allowed[1] || 0

        if current_count < @rate_limit
          # Add current request timestamp
          @redis.zadd(@redis_key, current_time, "#{current_time}-#{Random.rand(10000)}")

          # Set expiration to clean up old data
          @redis.expire(@redis_key, (@window_size * 2).ceil)

          @logger.debug "[RateLimitedClientWrapper] Allowed request (rate mode): count=#{current_count}, limit=#{@rate_limit}, window=#{@window_size}s"
          break
        else
          # Calculate how long to wait
          oldest_timestamp = @redis.zrange(@redis_key, 0, 0, with_scores: true)[0]
          if oldest_timestamp
            wait_time = oldest_timestamp[1] + @window_size - current_time
            @logger.info "[RateLimitedClientWrapper] Rate limited: count=#{current_count}, limit=#{@rate_limit}, waiting #{wait_time.round(3)}s"
            @kernel.sleep([ wait_time, 0.1 ].max) if wait_time > 0
          else
            @logger.info "[RateLimitedClientWrapper] Rate limited: count=#{current_count}, limit=#{@rate_limit}, waiting 0.1s (no oldest timestamp)"
            @kernel.sleep(0.1)
          end
        end
      end
    end

    def wait_for_credit_limit(method)
      method_str = method.to_s
      # Convert ruby method names to RPC method names
      rpc_method = case method_str
      when 'get_nonce' then 'eth_get_transaction_count'
      when 'get_balance' then 'eth_get_balance'
      when 'chain_id' then 'eth_chain_id'
      when 'call' then 'eth_call'
      else method_str
      end

      cost = CREDIT_COSTS[rpc_method]
      if cost.nil?
        @logger.warn "[RateLimitedClientWrapper] Unknown RPC method for credit cost: '#{rpc_method}' (original: '#{method_str}'). Using default cost: #{DEFAULT_CREDIT_COST}"
        cost = DEFAULT_CREDIT_COST
      end

      loop do
        current_time = @time.now.to_f

        # Use Redis pipeline for atomic operations
        allowed = @redis.pipelined do |pipe|
          # Remove old entries outside the window
          pipe.zremrangebyscore(@redis_key, '-inf', current_time - @window_size)

          # Sum current credits in the window
          pipe.zrange(@redis_key, 0, -1, with_scores: true)
        end

        current_entries = allowed[1] || []
        current_credits = current_entries.sum { |entry| entry[0].split('-')[1].to_f }

        if current_credits + cost <= @credit_limit
          # Add current request with its cost
          @redis.zadd(@redis_key, current_time, "#{current_time}-#{cost}")

          # Set expiration to clean up old data
          @redis.expire(@redis_key, (@window_size * 2).ceil)

          @logger.debug "[RateLimitedClientWrapper] Allowed request (credit mode): method=#{rpc_method}, cost=#{cost}, current_credits=#{current_credits}, limit=#{@credit_limit}, window=#{@window_size}s"
          break
        else
          # Calculate how long to wait based on oldest entry
          if current_entries.any?
            oldest_timestamp = current_entries.first[1]
            wait_time = oldest_timestamp + @window_size - current_time
            @logger.info "[RateLimitedClientWrapper] Credit limited: method=#{rpc_method}, cost=#{cost}, current_credits=#{current_credits}, limit=#{@credit_limit}, waiting #{wait_time.round(3)}s"
            @kernel.sleep([ wait_time, 0.1 ].max) if wait_time > 0
          else
            @logger.info "[RateLimitedClientWrapper] Credit limited: method=#{rpc_method}, cost=#{cost}, current_credits=#{current_credits}, limit=#{@credit_limit}, waiting 0.1s (no entries)"
            @kernel.sleep(0.1)
          end
        end
      end
    end
  end
end
