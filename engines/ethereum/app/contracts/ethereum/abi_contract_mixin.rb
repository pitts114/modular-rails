module Ethereum
  module AbiContractMixin
    def encode_function_call(function_abi, args)
      signature = "#{function_abi['name']}(" + function_abi['inputs'].map { |i| i['type'] }.join(',') + ")"
      selector = @eth_util.keccak256(signature)[0, 4].unpack1('H*')
      encoded_args = @abi_encoder.encode(function_abi['inputs'].map { |i| i['type'] }, args)
      encoded_args_hex = encoded_args.unpack1('H*')
      "0x" + selector + encoded_args_hex
    end

    def find_function_abi!(function_name, input_types = nil)
      function_abi = self.class::ABI.find do |f|
        f['name'] == function_name && f['type'] == 'function' &&
          (input_types.nil? || f['inputs'].map { |i| i['type'] } == input_types)
      end
      expected_sig = input_types ? "#{function_name}(#{input_types.join(',')})" : function_name
      raise "ABI for #{expected_sig} not found" unless function_abi
      function_abi
    end

    module ClassMethods
      def load_abi(path)
        JSON.parse(File.read(path))
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
