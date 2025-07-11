# frozen_string_literal: true

require 'eth'

module Ethereum
  class StandardArbErc20Contract
    include Ethereum::AbiContractMixin

    ABI_PATH = File.expand_path('../../../abi/standard_arb_erc20.json', __dir__)
    ABI = load_abi(ABI_PATH)

    def initialize(
      contract_address:,
      client: Ethereum::ClientProvider.client,
      contract: Eth::Contract.from_abi(name: 'StandardArbErc20', address: contract_address, abi: ABI),
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
      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end

    # Transfers tokens to a recipient
    # @param from [String] The Ethereum address of the sender
    # @param recipient [String] The Ethereum address of the recipient
    # @param amount [Integer] The amount to transfer
    def transfer(from:, recipient:, amount:)
      function_abi = find_function_abi!('transfer', [ 'address', 'uint256' ])
      data = encode_function_call(function_abi, [ recipient, amount ])
      @eth_contract_call_service.call_contract(
        contract_address: @contract_address,
        from: from,
        data: data
      )
    end
  end
end
