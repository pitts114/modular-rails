require 'rails_helper'

RSpec.describe Ethereum::AbiContractMixin do
  let(:mock_eth_util) { double(:eth_util) }
  let(:mock_abi_encoder) { double(:abi_encoder) }

  let(:harness_class) do
    Class.new do
      include Ethereum::AbiContractMixin
      attr_accessor :eth_util, :abi_encoder
      def initialize(eth_util, abi_encoder)
        @eth_util = eth_util
        @abi_encoder = abi_encoder
      end
    end
  end

  subject { harness_class.new(mock_eth_util, mock_abi_encoder) }

  describe '#encode_function_call' do
    it 'encodes the function call data as expected' do
      function_abi = {
        'name' => 'foo',
        'inputs' => [
          { 'name' => 'bar', 'type' => 'uint256' },
          { 'name' => 'baz', 'type' => 'address' }
        ]
      }
      args = [ 123, '0xabc' ]
      signature = 'foo(uint256,address)'
      selector = [ 0xde, 0xad, 0xbe, 0xef ].pack('C*')
      encoded_args = "\x01\x02\x03\x04"
      encoded_args_hex = '01020304'
      expected = '0xdeadbeef01020304'

      expect(mock_eth_util).to receive(:keccak256).with(signature).and_return(selector)
      expect(mock_abi_encoder).to receive(:encode).with([ 'uint256', 'address' ], args).and_return(encoded_args)
      expect(subject.encode_function_call(function_abi, args)).to eq(expected)
    end
  end

  describe '.load_abi' do
    it 'loads and parses the ABI from a file' do
      abi_hash = [ { 'name' => 'foo', 'type' => 'function' } ]
      Tempfile.create([ 'abi', '.json' ]) do |file|
        file.write(abi_hash.to_json)
        file.rewind
        expect(harness_class.load_abi(file.path)).to eq(abi_hash)
      end
    end
  end

  describe '#find_function_abi!' do
    let(:abi) do
      [
        { 'name' => 'foo', 'type' => 'function', 'inputs' => [ { 'type' => 'uint256' } ] },
        { 'name' => 'bar', 'type' => 'function', 'inputs' => [ { 'type' => 'address' }, { 'type' => 'uint256' } ] }
      ]
    end

    before do
      harness_class.const_set(:ABI, abi)
    end

    it 'finds the correct function ABI by name and input types' do
      expect(subject.find_function_abi!('foo', [ 'uint256' ])).to eq(abi[0])
      expect(subject.find_function_abi!('bar', [ 'address', 'uint256' ])).to eq(abi[1])
    end

    it 'raises an error if the function is not found' do
      expect { subject.find_function_abi!('baz', [ 'uint256' ]) }.to raise_error(/ABI for baz\(uint256\) not found/)
    end

    it 'raises an error if input types do not match' do
      expect { subject.find_function_abi!('foo', [ 'address' ]) }.to raise_error(/ABI for foo\(address\) not found/)
    end

    it 'finds by name only if input_types is nil' do
      expect(subject.find_function_abi!('foo')).to eq(abi[0])
    end
  end
end
