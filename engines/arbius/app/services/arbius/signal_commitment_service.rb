# frozen_string_literal: true

module Arbius
  class SignalCommitmentService
    def initialize(engine_contract: Ethereum::Public::EngineContract.new)
      @engine_contract = engine_contract
    end

    # Calls the EngineContract's signal_commitment method
    # @param from [String] Ethereum address submitting the commitment
    # @param commitment [String] Commitment hash (bytes32)
    def call(from:, commitment:)
      context = { class: 'Arbius::SignalCommitmentService', from: }
      @engine_contract.signal_commitment(from:, commitment:, context:)
    end
  end
end
