require 'spec_helper'
require 'eth_event_utils'

describe EthEventUtils do
  let(:abi) do
    [
      {
        "type" => "event",
        "name" => "TestEvent",
        "inputs" => [
          { "name" => "foo", "type" => "uint256" },
          { "name" => "bar", "type" => "address" }
        ]
      }
    ]
  end

  describe '.topic0_for' do
    it 'returns the correct topic0 for a valid event' do
      topic0 = described_class.topic0_for(event_name: 'TestEvent', abi: abi)
      expected = '0x' + Eth::Util.keccak256('TestEvent(uint256,address)').unpack1('H*')
      expect(topic0).to eq(expected)
    end

    it 'raises if the event is not found' do
      expect {
        described_class.topic0_for(event_name: 'MissingEvent', abi: abi)
      }.to raise_error(/not found in ABI/)
    end

    it 'returns the correct topic0 for SolutionSubmitted(address,bytes32)' do
      abi = [
        {
          "anonymous" => false,
          "inputs" => [
            {
              "indexed" => true,
              "internalType" => "address",
              "name" => "addr",
              "type" => "address"
            },
            {
              "indexed" => true,
              "internalType" => "bytes32",
              "name" => "task",
              "type" => "bytes32"
            }
          ],
          "name" => "SolutionSubmitted",
          "type" => "event"
        }
      ]
      topic0 = described_class.topic0_for(event_name: 'SolutionSubmitted', abi: abi)
      expect(topic0).to eq('0x957c18b5af8413899ea8a576a4d3fb16839a02c9fccfdce098b6d59ef248525b')
    end
  end
end
