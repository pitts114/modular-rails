# frozen_string_literal: true

require 'eth'

module Ethereum
  module Public
    class StandardArbErc20Contract
      include Ethereum::AbiContractMixin

      ABI_PATH = Rails.root.join('engines', 'ethereum', 'abi', 'standard_arb_erc20.json').to_s
      ABI = load_abi(ABI_PATH)

      def initialize(
        contract_address:,
        client: Ethereum::ClientProvider.client,
        contract: Eth::Contract.from_abi(name: 'StandardArbErc20', address: contract_address, abi: ABI),
        send_transaction_job: Ethereum::SendTransactionJob,
        ethereum_transaction_model: Ethereum::Transaction
      )
        @contract_address = contract_address
        @client = client
        @contract = contract
        @send_transaction_job = send_transaction_job
        @ethereum_transaction_model = ethereum_transaction_model
      end

      # Retrieves the balance of a specific account
      # @param account [String] The Ethereum address of the account
      # @return [BigDecimal] The balance of the account in the token's smallest unit
      # @raise [StandardError] If the contract call fails
      def balance_of(account:)
        @client.call(@contract, 'balanceOf', account)
      end

      # Retrieves the allowance for a spender from an owner
      # @param owner [String] The Ethereum address of the owner
      # @param spender [String] The Ethereum address of the spender
      # @return [BigDecimal] The allowance amount
      def allowance(owner:, spender:)
        @client.call(@contract, 'allowance', owner, spender)
      end

      # Approves a spender to spend a certain amount
      # @param from [String] The Ethereum address of the sender
      # @param spender [String] The Ethereum address of the spender
      # @param amount [Integer] The amount to approve
      def approve(from:, spender:, amount:)
        function_abi = find_function_abi!('approve', [ 'address', 'uint256' ])
        data = encode_function_call(function_abi, [ spender, amount ])
        enqueue_transaction(from:, data:)
      end

      # Transfers tokens to a recipient
      # @param from [String] The Ethereum address of the sender
      # @param recipient [String] The Ethereum address of the recipient
      # @param amount [Integer] The amount to transfer
      def transfer(from:, recipient:, amount:)
        function_abi = find_function_abi!('transfer', [ 'address', 'uint256' ])
        data = encode_function_call(function_abi, [ recipient, amount ])
        enqueue_transaction(from:, data:)
      end

      private

      def enqueue_transaction(from:, data:)
        chain_id = @client.chain_id
        ethereum_transaction = @ethereum_transaction_model.create!(
          from: from,
          to: @contract_address,
          data: data,
          value: 0,
          status: 'pending',
          chain_id: chain_id
        )
        @send_transaction_job.perform_later(from, chain_id)
        ethereum_transaction.id
      end
    end
  end
end
