# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::Public::EngineContract do
  let(:client) { double(:client, chain_id: 1) }
  let(:contract_address) { '0xengine' }
  let(:contract) { double(:contract) }
  let(:ethereum_transaction_model) { double(:ethereum_transaction_model) }
  let(:abi_encoder) { double(:abi_encoder) }
  let(:eth_util) { double(:eth_util) }
  let(:send_transaction_job) { double(:send_transaction_job) }
  let(:abi) { [ { 'name' => 'submitTask', 'inputs' => [] } ] }

  before do
    allow(described_class).to receive(:load_abi).and_return(abi)
    stub_const('ENV', ENV.to_hash.merge('ENGINE_CONTRACT_ADDRESS' => contract_address))
  end

  subject(:service) do
    described_class.new(
      client: client,
      contract_address: contract_address,
      contract: contract,
      ethereum_transaction_model: ethereum_transaction_model,
      abi_encoder: abi_encoder,
      eth_util: eth_util,
      send_transaction_job: send_transaction_job
    )
  end

  describe '#get_reward' do
    it 'calls the contract getReward method' do
      expect(client).to receive(:call).with(contract, 'getReward').and_return(123)
      expect(service.get_reward).to eq(123)
    end
  end

  describe '#submit_task' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xabc'
      allow(service).to receive(:find_function_abi!).with('submitTask', [ 'uint8', 'address', 'bytes32', 'uint256', 'bytes' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ 0, '0xowner', '0xmodel', 100, '0xinput' ]).and_return(data)
      transaction = double(id: 1)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.submit_task(from: '0xfrom', version: 0, owner: '0xowner', model: '0xmodel', fee: 100, input: '0xinput')
    end
  end

  describe '#signal_commitment' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xdead'
      allow(service).to receive(:find_function_abi!).with('signalCommitment', [ 'bytes32' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xcommit' ]).and_return(data)
      transaction = double(id: 2)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.signal_commitment(from: '0xfrom', commitment: '0xcommit')
    end
  end

  describe '#submit_solution' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xsol'
      allow(service).to receive(:find_function_abi!).with('submitSolution', [ 'bytes32', 'bytes' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xtask', '0xcid' ]).and_return(data)
      transaction = double(id: 3)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.submit_solution(from: '0xfrom', taskid: '0xtask', cid: '0xcid')
    end
  end

  describe '#generate_commitment' do
    it 'calls the contract generateCommitment method' do
      expect(client).to receive(:call).with(contract, 'generateCommitment', '0xsender', '0xtask', '0xcid').and_return('0xcommit')
      expect(service.generate_commitment(sender: '0xsender', taskid: '0xtask', cid: '0xcid')).to eq('0xcommit')
    end
  end

  describe '#vote_on_contestation' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xvote'
      allow(service).to receive(:find_function_abi!).with('voteOnContestation', [ 'bytes32', 'bool' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xtask', true ]).and_return(data)
      transaction = double(id: 4)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.vote_on_contestation(from: '0xfrom', taskid: '0xtask', yea: true)
    end
  end

  describe '#submit_contestation' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xcont'
      allow(service).to receive(:find_function_abi!).with('submitContestation', [ 'bytes32' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xtask' ]).and_return(data)
      transaction = double(id: 5)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.submit_contestation(from: '0xfrom', taskid: '0xtask')
    end
  end

  describe '#claim_solution' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xclaim'
      allow(service).to receive(:find_function_abi!).with('claimSolution', [ 'bytes32' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xtask' ]).and_return(data)
      transaction = double(id: 6)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.claim_solution(from: '0xfrom', taskid: '0xtask')
    end
  end

  describe '#min_claim_solution_time' do
    it 'calls the contract minClaimSolutionTime method' do
      expect(client).to receive(:call).with(contract, 'minClaimSolutionTime').and_return(42)
      expect(service.min_claim_solution_time).to eq(42)
    end
  end

  describe '#min_contestation_vote_period_time' do
    it 'calls the contract minContestationVotePeriodTime method' do
      expect(client).to receive(:call).with(contract, 'minContestationVotePeriodTime').and_return(100)
      expect(service.min_contestation_vote_period_time).to eq(100)
    end
  end

  describe '#contestation_vote_extension_time' do
    it 'calls the contract contestationVoteExtensionTime method' do
      expect(client).to receive(:call).with(contract, 'contestationVoteExtensionTime').and_return(200)
      expect(service.contestation_vote_extension_time).to eq(200)
    end
  end

  describe '#voting_period_ended' do
    it 'calls the contract votingPeriodEnded method and returns a boolean' do
      expect(client).to receive(:call).with(contract, 'votingPeriodEnded', '0xtaskid').and_return(true)
      expect(service.voting_period_ended(taskid: '0xtaskid')).to eq(true)
      expect(client).to receive(:call).with(contract, 'votingPeriodEnded', '0xothertask').and_return(false)
      expect(service.voting_period_ended(taskid: '0xothertask')).to eq(false)
    end
  end

  describe '#contestation_vote_finish' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xfinish'
      allow(service).to receive(:find_function_abi!).with('contestationVoteFinish', [ 'bytes32', 'uint32' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ '0xtaskid', 5 ]).and_return(data)
      transaction = double(id: 7)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.contestation_vote_finish(from: '0xfrom', taskid: '0xtaskid', amnt: 5)
    end
  end

  describe '#bulk_submit_solution' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xbulk'
      allow(service).to receive(:find_function_abi!).with('bulkSubmitSolution', [ 'bytes32[]', 'bytes[]' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ [ '0xtask1', '0xtask2' ], [ '0xcid1', '0xcid2' ] ]).and_return(data)
      transaction = double(id: 8)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: {}
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      service.bulk_submit_solution(from: '0xfrom', taskids: [ '0xtask1', '0xtask2' ], cids: [ '0xcid1', '0xcid2' ])
    end
  end

  describe '#bulk_submit_task' do
    it 'creates a pending transaction and enqueues the job' do
      function_abi = double(:function_abi)
      data = '0xbulktask'
      allow(service).to receive(:find_function_abi!).with('bulkSubmitTask', [ 'uint8', 'address', 'bytes32', 'uint256', 'bytes', 'uint256' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ 1, '0xowner', '0xmodel', 42, '0xinput', 3 ]).and_return(data)
      transaction = double(id: 9)
      expect(ethereum_transaction_model).to receive(:create!).with(
        from: '0xfrom',
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: { foo: 'bar' }
      ).and_return(transaction)
      expect(send_transaction_job).to receive(:perform_later).with('0xfrom', 1)
      result = service.bulk_submit_task(from: '0xfrom', version: 1, owner: '0xowner', model: '0xmodel', fee: 42, input: '0xinput', n: 3, context: { foo: 'bar' })
      expect(result).to eq(9)
    end
  end

  describe '#get_validator_minimum' do
    it 'calls the contract getValidatorMinimum method' do
      expect(client).to receive(:call).with(contract, 'getValidatorMinimum').and_return(1000)
      expect(service.get_validator_minimum).to eq(1000)
    end
  end

  describe '#get_validator_deposit' do
    it 'calls the contract validators method and returns the staked amount' do
      expect(client).to receive(:call).with(contract, 'validators', '0xvalidator').and_return([ 500, 1234567890, '0xvalidator' ])
      expect(service.get_validator_deposit(address: '0xvalidator')).to eq(500)
    end
  end

  describe '#validator_deposit' do
    let(:from) { '0xfrom' }
    let(:amount) { 1234 }
    let(:context) { { foo: 'bar' } }
    let(:function_abi) { double(:function_abi) }
    let(:data) { '0xvaldeposit' }
    let(:transaction) { double(id: 42) }

    before do
      allow(service).to receive(:find_function_abi!).with('validatorDeposit', [ 'address', 'uint256' ]).and_return(function_abi)
      allow(service).to receive(:encode_function_call).with(function_abi, [ from, amount ]).and_return(data)
      allow(ethereum_transaction_model).to receive(:create!).with(
        from: from,
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: context
      ).and_return(transaction)
      allow(send_transaction_job).to receive(:perform_later).with(from, 1)
    end

    it 'creates a pending validator deposit transaction and enqueues the job' do
      result = service.validator_deposit(from: from, amount: amount, context: context)
      expect(result).to eq(42)
      expect(service).to have_received(:find_function_abi!).with('validatorDeposit', [ 'address', 'uint256' ])
      expect(service).to have_received(:encode_function_call).with(function_abi, [ from, amount ])
      expect(ethereum_transaction_model).to have_received(:create!).with(
        from: from,
        to: contract_address,
        data: data,
        value: 0,
        status: 'pending',
        chain_id: 1,
        context: context
      )
      expect(send_transaction_job).to have_received(:perform_later).with(from, 1)
    end
  end
end
