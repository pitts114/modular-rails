# frozen_string_literal: true

require 'address_provider'
require 'eth'

describe AddressProvider do
  let(:aius_address) { '0x01c36ca785bbfbe8744252189feaa0163dcc706f' }
  let(:engine_address) { '0x53c9f1a7aff9f5b1028712e29bc2206ef9241385' }
  let(:storage_address) { '0x82a2116d91b5e8dd1b3a1e84cd842d27dbef61b4' }
  let(:bulk_tasks_address) { '0x75b9acacaeab562c8fc0205df208495836be9079' }

  before do
    allow(ENV).to receive(:fetch).with('AIUS_CONTRACT_ADDRESS').and_return(aius_address)
    allow(ENV).to receive(:fetch).with('ENGINE_CONTRACT_ADDRESS').and_return(engine_address)
  end

  it 'returns the checksummed AIUS contract address' do
    expect(AddressProvider.aius_contract_address).to eq("0x01C36ca785bbfBe8744252189feaa0163DCC706F")
  end

  it 'returns the checksummed ENGINE contract address' do
    expect(AddressProvider.engine_contract_address).to eq("0x53c9F1a7AfF9f5B1028712e29BC2206Ef9241385")
  end

  it 'returns the checksummed BULK_TASKS contract address' do
    allow(ENV).to receive(:fetch).with('BULK_TASKS_CONTRACT_ADDRESS').and_return(bulk_tasks_address)
    expect(AddressProvider.bulk_tasks_contract_address).to eq("0x75B9acacaEaB562c8Fc0205df208495836bE9079")
  end
end
