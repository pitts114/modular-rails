# frozen_string_literal: true

require 'eth'

module Ethereum
  class ClientProvider
    def self.client
      @client ||= begin
        raw_client = Eth::Client.create(ENV.fetch('ETHEREUM_NODE_URL'))

        # Configure rate limiting based on environment variables
        use_credits = ENV['ETHEREUM_USE_CREDIT_LIMITING'] == 'true'
        rate_limit = ENV.fetch('ETHEREUM_RATE_LIMIT', '3.0').to_f
        credit_limit = ENV.fetch('ETHEREUM_CREDIT_LIMIT', '500').to_f

        RateLimitedClientWrapper.new(
          raw_client,
          rate_limit: rate_limit,
          use_credits: use_credits,
          credit_limit: credit_limit
        )
      end
    end
  end
end
