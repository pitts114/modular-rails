module Ethereum
  class LatestBlockNumberService
    def initialize(eth_client: Ethereum::ClientProvider.client)
      @eth_client = eth_client
    end

    def call
      latest_block = @eth_client.eth_get_block_by_number('latest', false)["result"]
      latest_block['number'].to_i(16)
    end
  end
end
