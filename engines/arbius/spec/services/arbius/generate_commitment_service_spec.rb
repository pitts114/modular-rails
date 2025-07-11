# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::GenerateCommitmentService do
  let(:abi_util) { double(:abi_util) }
  let(:keccak_util) { double(:keccak_util) }
  let(:engine_contract) { double(:engine_contract) }
  let(:service) { described_class.new(abi_util: abi_util, keccak_util: keccak_util, engine_contract: engine_contract) }

  describe '#generate_commitment' do
    it 'encodes and hashes the arguments as expected' do
      sender = '0x1111111111111111111111111111111111111111'
      taskid = '0x2222222222222222222222222222222222222222222222222222222222222222'
      cid = '0xdeadbeef'
      encoded = 'encoded-bytes'
      hash = "\x12" * 32

      expect(abi_util).to receive(:encode).with([ 'address', 'bytes32', 'bytes' ], [ sender, taskid, cid ]).and_return(encoded)
      expect(keccak_util).to receive(:keccak256).with(encoded).and_return(hash)

      result = service.generate_commitment(sender: sender, taskid: taskid, cid: cid)
      expect(result).to eq('0x' + hash.unpack1('H*'))
      expect(result).to match(/^0x[0-9a-f]{64}$/)
    end
  end

  describe '#generate_commitment_onchain' do
    it 'delegates to engine_contract.generate_commitment with the correct args' do
      sender = '0x1'
      taskid = '0x2'
      cid = '0xdeadbeef'
      expect(engine_contract).to receive(:generate_commitment).with(sender: sender, taskid: taskid, cid: cid).and_return('0x1234')
      result = service.generate_commitment_onchain(sender: sender, taskid: taskid, cid: cid)
      expect(result).to eq('0x1234')
    end
  end
end
