# frozen_string_literal: true

require 'address_provider'
require 'eth'

module Ethereum
  module Public
    class BulkTasksContract
      include Ethereum::AbiContractMixin

      ABI_PATH = Rails.root.join('engines', 'ethereum', 'abi', 'bulk_tasks.json').to_s
      ABI = load_abi(ABI_PATH)

      def initialize(
        client: Ethereum::ClientProvider.client,
        contract_address: AddressProvider.bulk_tasks_contract_address,
        contract: Eth::Contract.from_abi(name: 'BulkTasks', address: contract_address, abi: ABI),
        ethereum_transaction_model: Ethereum::Transaction,
        abi_encoder: Eth::Abi,
        eth_util: Eth::Util,
        send_transaction_job: Ethereum::SendTransactionJob
      )
        @contract_address = contract_address
        @client = client
        @contract = contract
        @ethereum_transaction_model = ethereum_transaction_model
        @abi_encoder = abi_encoder
        @eth_util = eth_util
        @send_transaction_job = send_transaction_job
      end

      def bulk_signal_commitment(from:, commitments:, context: {})
        function_abi = find_function_abi!('bulkSignalCommitment', [ 'bytes32[]' ])
        data = encode_function_call(function_abi, [ commitments ])

        enqueue_transaction(from:, data:, context:)
      end

      def claim_solutions(from:, taskids:, context: {})
        function_abi = find_function_abi!('claimSolutions', [ 'bytes32[]' ])
        data = encode_function_call(function_abi, [ taskids ])

        enqueue_transaction(from:, data:, context:)
      end

      private

      def enqueue_transaction(from:, data:, context:)
        chain_id = @client.chain_id
        ethereum_transaction = @ethereum_transaction_model.create!(
          from:,
          to: @contract_address,
          data:,
          value: 0,
          status: 'pending',
          chain_id:,
          context:
        )
        @send_transaction_job.perform_later(from, chain_id)
        ethereum_transaction.id
      end
    end
  end
end
