# frozen_string_literal: true

require 'address_provider'
require 'eth'

module Ethereum
  module Public
    class EngineContract
      include Ethereum::AbiContractMixin

      ABI_PATH = Rails.root.join('engines', 'ethereum', 'abi', 'engine.json').to_s
      ABI = load_abi(ABI_PATH)

      def initialize(
        client: Ethereum::ClientProvider.client,
        contract_address: AddressProvider.engine_contract_address,
        contract: Eth::Contract.from_abi(name: 'Engine', address: contract_address, abi: ABI),
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

      def submit_task(from:, version: 0, owner:, model:, fee:, input:, context: {})
        function_abi = find_function_abi!('submitTask', [ 'uint8', 'address', 'bytes32', 'uint256', 'bytes' ])
        data = encode_function_call(function_abi, [ version, owner, model, fee, input ])

        enqueue_transaction(from:, data:, context:)
      end

      def get_reward
        @client.call(@contract, 'getReward')
      end

      def signal_commitment(from:, commitment:, context: {})
        function_abi = find_function_abi!('signalCommitment', [ 'bytes32' ])
        data = encode_function_call(function_abi, [ commitment ])

        enqueue_transaction(from:, data:, context:)
      end

      def submit_solution(from:, taskid:, cid:, context: {})
        function_abi = find_function_abi!('submitSolution', [ 'bytes32', 'bytes' ])
        data = encode_function_call(function_abi, [ taskid, cid ])

        enqueue_transaction(from:, data:, context:)
      end

      def generate_commitment(sender:, taskid:, cid:)
        @client.call(@contract, 'generateCommitment', sender, taskid, cid)
      end

      def vote_on_contestation(from:, taskid:, yea:, context: {})
        function_abi = find_function_abi!('voteOnContestation', [ 'bytes32', 'bool' ])
        data = encode_function_call(function_abi, [ taskid, yea ])
        enqueue_transaction(from:, data:, context:)
      end

      def submit_contestation(from:, taskid:, context: {})
        function_abi = find_function_abi!('submitContestation', [ 'bytes32' ])
        data = encode_function_call(function_abi, [ taskid ])
        enqueue_transaction(from:, data:, context:)
      end

      def claim_solution(from:, taskid:, context: {})
        function_abi = find_function_abi!('claimSolution', [ 'bytes32' ])
        data = encode_function_call(function_abi, [ taskid ])
        enqueue_transaction(from:, data:, context:)
      end

      def min_claim_solution_time
        @client.call(@contract, 'minClaimSolutionTime')
      end

      def voting_period_ended(taskid:)
        @client.call(@contract, 'votingPeriodEnded', taskid)
      end

      def min_contestation_vote_period_time
        @client.call(@contract, 'minContestationVotePeriodTime')
      end

      def contestation_vote_extension_time
        @client.call(@contract, 'contestationVoteExtensionTime')
      end

      def contestation_vote_finish(from:, taskid:, amnt:, context: {})
        function_abi = find_function_abi!('contestationVoteFinish', [ 'bytes32', 'uint32' ])
        data = encode_function_call(function_abi, [ taskid, amnt ])
        enqueue_transaction(from:, data:, context:)
      end

      def bulk_submit_solution(from:, taskids:, cids:, context: {})
        function_abi = find_function_abi!('bulkSubmitSolution', [ 'bytes32[]', 'bytes[]' ])
        data = encode_function_call(function_abi, [ taskids, cids ])

        enqueue_transaction(from:, data:, context:)
      end

      def bulk_submit_task(from:, version: 0, owner:, model:, fee:, input:, n:, context: {})
        function_abi = find_function_abi!('bulkSubmitTask', [ 'uint8', 'address', 'bytes32', 'uint256', 'bytes', 'uint256' ])
        data = encode_function_call(function_abi, [ version, owner, model, fee, input, n ])

        enqueue_transaction(from:, data:, context:)
      end

      def get_validator_minimum
        @client.call(@contract, 'getValidatorMinimum')
      end

      def get_validator_deposit(address:)
        result = @client.call(@contract, 'validators', address)
        result[0] # returns staked amount from the struct
      end

      def validator_deposit(from:, amount:, context: {})
        function_abi = find_function_abi!('validatorDeposit', [ 'address', 'uint256' ])
        data = encode_function_call(function_abi, [ from, amount ])

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
