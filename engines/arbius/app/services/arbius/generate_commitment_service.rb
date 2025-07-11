# frozen_string_literal: true

require 'eth'

module Arbius
  class GenerateCommitmentService
    # Dependency injection for utilities (default to Eth::Abi and Eth::Util)
    def initialize(eth_util: Eth::Util, abi_util: Eth::Abi, keccak_util: Eth::Util, engine_contract: Ethereum::EngineContract.new)
      @abi_util = abi_util
      @eth_util = eth_util
      @keccak_util = keccak_util
      @engine_contract = engine_contract
    end

    # Generates a commitment hash for a given sender, taskid, and cid, matching the Solidity smart contract logic
    # @param sender [String] Ethereum address of the sender (hex string)
    # @param taskid [String] Task hash (32-byte hex string)
    # @param cid [String] IPFS CID as bytes (hex string or binary)
    # @return [String] 32-byte hex string commitment hash
    def generate_commitment(sender:, taskid:, cid:)
      encoded = @abi_util.encode([ 'address', 'bytes32', 'bytes' ], [ sender, taskid, cid ])
      hash = @keccak_util.keccak256(encoded)
      '0x' + hash.unpack1('H*')
    end

    # Calls the engine contract's generateCommitment method
    # @param sender [String] Ethereum address of the sender (hex string)
    # @param taskid [String] Task hash (32-byte hex string)
    # @param cid [String] IPFS CID as bytes (hex string or binary)
    # @return [String] 32-byte hex string commitment hash
    def generate_commitment_onchain(sender:, taskid:, cid:)
      @engine_contract.generate_commitment(sender:, taskid:, cid:)
    end
  end
end
