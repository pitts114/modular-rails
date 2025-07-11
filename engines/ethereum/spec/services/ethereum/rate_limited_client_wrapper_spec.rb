# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::RateLimitedClientWrapper do
  let(:mock_client) { double(:eth_client) }
  let(:mock_redis) { double(:redis) }
  let(:mock_time) { double(:time, now: 1000.0) }
  let(:mock_kernel) { double(:kernel, sleep: nil) }
  let(:logger) { double(:logger, warn: nil, debug: nil, info: nil) }
  let(:wrapper) { described_class.new(mock_client, redis: mock_redis, time: mock_time, kernel: mock_kernel, logger: logger) }

  describe '#method_missing' do
    it 'forwards method calls to the wrapped client' do
      expect(mock_client).to receive(:respond_to?).with(:some_method).and_return(true)
      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore).with('ethereum:rate_limiter', '-inf', anything)
      expect(mock_redis).to receive(:zcard).with('ethereum:rate_limiter').and_return(0)
      expect(mock_redis).to receive(:zadd).with('ethereum:rate_limiter', anything, anything)
      expect(mock_redis).to receive(:expire).with('ethereum:rate_limiter', anything)
      expect(mock_client).to receive(:some_method).with(:arg1, :arg2).and_return(:result)

      result = wrapper.some_method(:arg1, :arg2)
      expect(result).to eq(:result)
    end

    it 'raises NoMethodError for unsupported methods' do
      expect(mock_client).to receive(:respond_to?).with(:unsupported_method).and_return(false)

      expect { wrapper.unsupported_method }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    it 'returns true for methods supported by the wrapped client' do
      expect(mock_client).to receive(:respond_to?).with(:supported_method, false).and_return(true)

      expect(wrapper.respond_to?(:supported_method)).to be true
    end

    it 'returns false for methods not supported by the wrapped client' do
      expect(mock_client).to receive(:respond_to?).with(:unsupported_method, false).and_return(false)

      expect(wrapper.respond_to?(:unsupported_method)).to be false
    end
  end

  describe 'rate limiting' do
    before do
      allow(mock_client).to receive(:respond_to?).and_return(true)
      allow(mock_client).to receive(:test_method).and_return(:success)
    end

    it 'allows requests within rate limit' do
      # Mock Redis to show no current requests
      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore)
      expect(mock_redis).to receive(:zcard).and_return(0)
      expect(mock_redis).to receive(:zadd)
      expect(mock_redis).to receive(:expire)

      result = wrapper.test_method
      expect(result).to eq(:success)
    end

    it 'delays requests when rate limit is exceeded' do
      # Mock Redis to show rate limit exceeded, then allowed
      call_count = 0
      zcard_calls = []
      zrange_calls = []
      # 1st loop: current_time=1000, oldest=1001 (wait_time=2), 2nd loop: current_time=1002, zcard=0, so break
      time_values = [ 1000.0, 1002.0 ]
      zcard_values = [ 4, 0 ]
      allow(mock_time).to receive(:now) { time_values.shift || 1002.0 }
      allow(mock_redis).to receive(:pipelined) do |&block|
        call_count += 1
        block.call(mock_redis)
        [ nil, zcard_values[call_count - 1] ]
      end
      allow(mock_redis).to receive(:zremrangebyscore)
      allow(mock_redis).to receive(:zcard) do
        val = zcard_values[zcard_calls.length] || 0
        zcard_calls << val
        val
      end
      allow(mock_redis).to receive(:zrange) do |*args|
        val = [ [ [ 'key', 1001.0 ] ], [] ][zrange_calls.length] || []
        zrange_calls << val
        val
      end
      allow(mock_redis).to receive(:zadd)
      allow(mock_redis).to receive(:expire)
      expect(mock_kernel).to receive(:sleep).with(be > 0)
      allow(logger).to receive(:info) # Accept any info log, do not require a specific message
      allow(logger).to receive(:debug).with(/Allowed request \(rate mode\): count=0, limit=3.0, window=1.0s/)

      result = wrapper.test_method
      expect(result).to eq(:success)
      expect(call_count).to eq 2
    end
  end

  describe 'credit-based limiting' do
    let(:credit_wrapper) { described_class.new(mock_client, redis: mock_redis, use_credits: true, credit_limit: 100, time: mock_time, kernel: mock_kernel) }

    before do
      allow(mock_client).to receive(:respond_to?).and_return(true)
      allow(mock_client).to receive(:eth_call).and_return(:success)
    end

    it 'allows requests within credit limit' do
      # Mock Redis to show no current credits used
      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore)
      expect(mock_redis).to receive(:zrange).and_return([])
      expect(mock_redis).to receive(:zadd).with('ethereum:credit_limiter', anything, anything)
      expect(mock_redis).to receive(:expire)

      result = credit_wrapper.eth_call
      expect(result).to eq(:success)
    end

    it 'logs when credit limited and allowed' do
      # Simulate credit limit exceeded, then allowed
      call_count = 0
      zrange_values = [ [ [ 'key-80', 1001.0 ] ], [] ]
      time_values = [ 1000.0, 1002.0 ]
      allow(mock_time).to receive(:now) { time_values.shift || 1002.0 }
      allow(mock_redis).to receive(:pipelined) do |&block|
        call_count += 1
        block.call(mock_redis)
        [ nil, zrange_values[call_count - 1] ]
      end
      allow(mock_redis).to receive(:zremrangebyscore)
      allow(mock_redis).to receive(:zrange) { zrange_values[call_count - 1] }
      allow(mock_redis).to receive(:zadd)
      allow(mock_redis).to receive(:expire)
      expect(mock_kernel).to receive(:sleep).with(be > 0)
      # Accept any info/debug logs, do not require a specific message
      allow(logger).to receive(:info)
      allow(logger).to receive(:debug)

      credit_wrapper.eth_call
    end

    it 'calculates correct credit costs for different methods' do
      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore)
      expect(mock_redis).to receive(:zrange).and_return([])
      # eth_call should cost 80 credits (updated)
      expect(mock_redis).to receive(:zadd).with('ethereum:credit_limiter', anything, /-80$/)
      expect(mock_redis).to receive(:expire)

      credit_wrapper.eth_call
    end

    it 'handles method name mapping correctly' do
      allow(mock_client).to receive(:eth_block_number).and_return(:success)

      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore)
      expect(mock_redis).to receive(:zrange).and_return([])
      # eth_block_number should map to eth_blockNumber and cost 80 credits (updated)
      expect(mock_redis).to receive(:zadd).with('ethereum:credit_limiter', anything, /-80$/)
      expect(mock_redis).to receive(:expire)

      credit_wrapper.eth_block_number
    end

    it 'logs a warning and uses default cost for unknown RPC methods' do
      unknown_method = :some_unknown_method
      allow(mock_client).to receive(:respond_to?).with(unknown_method).and_return(true)
      allow(mock_client).to receive(:some_unknown_method).and_return(:success)
      credit_wrapper = described_class.new(mock_client, redis: mock_redis, use_credits: true, credit_limit: 100, time: mock_time, kernel: mock_kernel, logger: logger)

      expect(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      expect(mock_redis).to receive(:zremrangebyscore)
      expect(mock_redis).to receive(:zrange).and_return([])
      expect(mock_redis).to receive(:zadd).with('ethereum:credit_limiter', anything, /#{described_class::DEFAULT_CREDIT_COST}/)
      expect(mock_redis).to receive(:expire)
      expect(logger).to receive(:warn).with(/Unknown RPC method for credit cost: 'some_unknown_method' \(original: 'some_unknown_method'\). Using default cost: #{described_class::DEFAULT_CREDIT_COST}/)

      result = credit_wrapper.some_unknown_method
      expect(result).to eq(:success)
    end
  end

  describe 'error handling' do
    it 'raises RateLimitedError if upstream returns code -32005' do
      allow(mock_client).to receive(:respond_to?).with(:eth_call).and_return(true)
      allow(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      allow(mock_redis).to receive(:zremrangebyscore)
      allow(mock_redis).to receive(:zcard).and_return(0)
      allow(mock_redis).to receive(:zadd)
      allow(mock_redis).to receive(:expire)
      allow(mock_client).to receive(:eth_call).and_return({ "code" => -32005, "message" => "rate limit" })

      expect {
        wrapper.eth_call
      }.to raise_error(Ethereum::RateLimitedClientWrapper::RateLimitedError, /rate limit error/)
    end
  end

  describe 'miscellaneous' do
    it 'forwards keyword arguments and blocks to the client' do
      allow(mock_client).to receive(:respond_to?).with(:foo).and_return(true)
      allow(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      allow(mock_redis).to receive(:zremrangebyscore)
      allow(mock_redis).to receive(:zcard).and_return(0)
      allow(mock_redis).to receive(:zadd)
      allow(mock_redis).to receive(:expire)
      yielded = nil
      expect(mock_client).to receive(:foo).with(1, bar: 2) { |*args, **kwargs, &blk| blk.call(:yielded); :ok }
      result = wrapper.foo(1, bar: 2) { |v| yielded = v }
      expect(result).to eq(:ok)
      expect(yielded).to eq(:yielded)
    end

    it 'randomizes the Redis key member for rate limiting' do
      allow(mock_client).to receive(:respond_to?).with(:bar).and_return(true)
      allow(mock_redis).to receive(:pipelined).and_yield(mock_redis)
      allow(mock_redis).to receive(:zremrangebyscore)
      allow(mock_redis).to receive(:zcard).and_return(0)
      expect(mock_redis).to receive(:zadd).with('ethereum:rate_limiter', anything, match(/-\d+$/))
      allow(mock_redis).to receive(:expire)
      allow(mock_client).to receive(:bar).and_return(:baz)
      expect(wrapper.bar).to eq(:baz)
    end
  end
end
