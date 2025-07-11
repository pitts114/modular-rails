# frozen_string_literal: true

require 'address_provider'
require 'eth'

module Ethereum
  class EngineContract
    include Ethereum::AbiContractMixin

    ABI_PATH = File.expand_path('../../../abi/engine.json', __dir__)
    ABI = load_abi(ABI_PATH)

    def initialize(
      client: Ethereum::ClientProvider.client,
      contract_address: AddressProvider.engine_contract_address,
      contract: Eth::Contract.from_abi(name: 'Engine', address: contract_address, abi: ABI),
      eth_contract_call_service: Ethereum::EthContractCallService.new,
      abi_encoder: Eth::Abi,
      eth_util: Eth::Util
      )
      @contract_address = contract_address
      @client = client
      @contract = contract
      @eth_contract_call_service = eth_contract_call_service
      @abi_encoder = abi_encoder
      @eth_util = eth_util
    end

    def submit_task(from:, version: 0, owner:, model:, fee:, input:)
      function_abi = find_function_abi!('submitTask', [ 'uint8', 'address', 'bytes32', 'uint256', 'bytes' ])
      data = encode_function_call(function_abi, [ version, owner, model, fee, input ])

      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    def get_reward
      @client.call(@contract, 'getReward')
    end

    def signal_commitment(from:, commitment:)
      function_abi = find_function_abi!('signalCommitment', [ 'bytes32' ])
      data = encode_function_call(function_abi, [ commitment ])

      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    def submit_solution(from:, taskid:, cid:)
      function_abi = find_function_abi!('submitSolution', [ 'bytes32', 'bytes' ])
      data = encode_function_call(function_abi, [ taskid, cid ])

      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    def generate_commitment(sender:, taskid:, cid:)
      @client.call(@contract, 'generateCommitment', sender, taskid, cid)
    end

    def vote_on_contestation(from:, taskid:, yea:)
      function_abi = find_function_abi!('voteOnContestation', [ 'bytes32', 'bool' ])
      data = encode_function_call(function_abi, [ taskid, yea ])
      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    def submit_contestation(from:, taskid:)
      function_abi = find_function_abi!('submitContestation', [ 'bytes32' ])
      data = encode_function_call(function_abi, [ taskid ])
      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    def claim_solution(from:, taskid:)
      function_abi = find_function_abi!('claimSolution', [ 'bytes32' ])
      data = encode_function_call(function_abi, [ taskid ])
      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end
  end
end
