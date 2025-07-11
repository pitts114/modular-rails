# frozen_string_literal: true

module Ethereum
  class SendTransactionJob < ApplicationJob
    queue_as :ethereum_send_transaction

    def perform(address, chain_id)
      Ethereum::SendTransactionService.new.call(address:, chain_id:)
    end
  end
end
