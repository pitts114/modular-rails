# frozen_string_literal: true

require 'rails_helper'

module Ethereum
  RSpec.describe EngineContract do
    let(:mock_client) { double(:client_provider) }
    let(:mock_contract) { double(:contract) }
    let(:mock_eth_contract_call_service) { double(:eth_contract_call_service) }
    let(:mock_abi_encoder) { double(:abi_encoder) }
    let(:mock_eth_util) { double(:eth_util) }
    let(:contract_address) { '0x1234567890abcdef1234567890abcdef12345678' }

    before do
      allow(ENV).to receive(:fetch).with('ENGINE_CONTRACT_ADDRESS').and_return(contract_address)
    end

    subject do
      described_class.new(
        client: mock_client,
        contract_address: contract_address,
        contract: mock_contract,
        eth_contract_call_service: mock_eth_contract_call_service,
        abi_encoder: mock_abi_encoder,
        eth_util: mock_eth_util
      )
    end

    describe '#get_reward' do
      it 'calls the contract getReward function' do
        expect(mock_client).to receive(:call).with(mock_contract, 'getReward').and_return(42)
        expect(subject.get_reward).to eq(42)
      end
    end

    describe '#encode_function_call' do
      let(:function_abi) do
        {
          'name' => 'foo',
          'inputs' => [
            { 'name' => 'bar', 'type' => 'uint256' },
            { 'name' => 'baz', 'type' => 'address' }
          ]
        }
      end
      let(:args) { [ 123, '0xabc' ] }
      let(:signature) { 'foo(uint256,address)' }
      let(:selector) { 'deadbeef' }
      let(:encoded_args) { "\x01\x02\x03\x04" }
      let(:encoded_args_hex) { '01020304' }

      it 'encodes the function call data' do
        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xde, 0xad, 0xbe, 0xef ].pack('C*') + 'extra')
        expect(mock_abi_encoder).to receive(:encode).with([ 'uint256', 'address' ], args).and_return(encoded_args)
        # Let unpack1 run as normal on the string
        expect(subject.send(:encode_function_call, function_abi, args)).to eq('0xdeadbeef01020304')
      end
    end

    describe '#submit_task' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        version = 1
        owner = '0xdef'
        model = '0x123'
        fee = 1000
        input = '0xdeadbeef'
        signature = 'submitTask(uint8,address,bytes32,uint256,bytes)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          %w[uint8 address bytes32 uint256 bytes],
          [ version, owner, model, fee, input ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.submit_task(from: from, version: version, owner: owner, model: model, fee: fee, input: input)
      end
    end

    describe '#signal_commitment' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        commitment = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        signature = 'signalCommitment(bytes32)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          [ 'bytes32' ],
          [ commitment ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.signal_commitment(from: from, commitment: commitment)
      end
    end

    describe '#submit_solution' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        cid = '0xdeadbeef'
        signature = 'submitSolution(bytes32,bytes)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          [ 'bytes32', 'bytes' ],
          [ taskid, cid ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.submit_solution(from: from, taskid: taskid, cid: cid)
      end
    end

    describe '#generate_commitment' do
      it 'calls the contract generateCommitment function with sender, taskid, and cid' do
        sender = '0xabc'
        taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        cid = '0xdeadbeef'
        expected_commitment = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        expect(mock_client).to receive(:call).with(mock_contract, 'generateCommitment', sender, taskid, cid).and_return(expected_commitment)
        expect(subject.generate_commitment(sender: sender, taskid: taskid, cid: cid)).to eq(expected_commitment)
      end
    end

    describe '#vote_on_contestation' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        yea = true
        signature = 'voteOnContestation(bytes32,bool)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          [ 'bytes32', 'bool' ],
          [ taskid, yea ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.vote_on_contestation(from: from, taskid: taskid, yea: yea)
      end
    end

    describe '#submit_contestation' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        signature = 'submitContestation(bytes32)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          [ 'bytes32' ],
          [ taskid ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.submit_contestation(from: from, taskid: taskid)
      end
    end

    describe '#claim_solution' do
      it 'encodes and calls the contract with correct data' do
        from = '0xabc'
        taskid = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        signature = 'claimSolution(bytes32)'
        encoded_args = "\x01\x02\x03"
        data = '0xcafebabe010203'

        expect(mock_eth_util).to receive(:keccak256).with(signature).and_return([ 0xca, 0xfe, 0xba, 0xbe ].pack('C*'))
        expect(mock_abi_encoder).to receive(:encode).with(
          [ 'bytes32' ],
          [ taskid ]
        ).and_return(encoded_args)
        expect(mock_eth_contract_call_service).to receive(:call_contract).with(
          contract_address: contract_address,
          from: from,
          data: data
        )

        subject.claim_solution(from: from, taskid: taskid)
      end
    end
  end
end
