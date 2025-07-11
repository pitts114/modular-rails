require 'rails_helper'

RSpec.describe Arbius::ValidatorRepository do
  let(:repository) { described_class.new }

  describe '#find_addresses_excluding' do
    it 'returns addresses not in the exclude list' do
      Arbius::Validator.create!(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045')
      Arbius::Validator.create!(address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b')
      Arbius::Validator.create!(address: '0x1111111111111111111111111111111111111111')
      result = repository.find_addresses_excluding(exclude_addresses: [ '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', '0xab5801a7d398351b8be11c439e05c5b3259aec9b' ])
      expect(result).to match_array([ '0x1111111111111111111111111111111111111111', '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B' ])
    end
  end
end
