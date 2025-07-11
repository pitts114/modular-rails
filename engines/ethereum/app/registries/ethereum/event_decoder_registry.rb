# frozen_string_literal: true

require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_task_submitted_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_signal_commitment_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_solution_claimed_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_solution_submitted_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_contestation_submitted_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_contestation_vote_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_contestation_vote_finish_decoder')
require Rails.root.join('engines', 'ethereum', 'lib', 'ethereum', 'engine_validator_deposit_decoder')

# Central registry for all event decoders, contracts, and event names.
# Update this constant to add or remove supported events.
module Ethereum
  module EventDecoderRegistry
    # Each entry: {
    #   address: <contract address>,
    #   event_name: <event name>,
    #   decoder: <decoder class/instance>,
    #   contract: <contract instance>
    # }
    ENTRIES = [
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'TaskSubmitted',
        decoder: Ethereum::EngineTaskSubmittedDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'SignalCommitment',
        decoder: Ethereum::EngineSignalCommitmentDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'SolutionSubmitted',
        decoder: Ethereum::EngineSolutionSubmittedDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'ContestationSubmitted',
        decoder: Ethereum::EngineContestationSubmittedDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'ContestationVote',
        decoder: Ethereum::EngineContestationVoteDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'SolutionClaimed',
        decoder: Ethereum::EngineSolutionClaimedDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'ContestationVoteFinish',
        decoder: Ethereum::EngineContestationVoteFinishDecoder,
        contract: Ethereum::ContractProvider.engine
      },
      {
        address: Ethereum::ContractProvider.engine.address,
        event_name: 'ValidatorDeposit',
        decoder: Ethereum::EngineValidatorDepositDecoder,
        contract: Ethereum::ContractProvider.engine
      }
      # Add more entries here as needed
    ]
  end
end
