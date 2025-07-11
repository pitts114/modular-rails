# frozen_string_literal: true

require 'rails_helper'

describe Arbius::SetupService do
  let(:from_address) { '0x1234567890123456789012345678901234567890' }
  let(:contract_address) { '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd' }
  let(:engine_contract_address) { '0xfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed' }
  let(:mock_contract) { double(:standard_arb_erc20_contract) }
  let(:engine_contract) { double(:engine_contract) }
  let(:standard_arb_erc20_contract) { double(:standard_arb_erc20_contract_class) }
  let(:service) do
    described_class.new(
      address_provider: AddressProvider,
      standard_arb_erc20_contract: standard_arb_erc20_contract,
      engine_contract: engine_contract
    )
  end

  before do
    allow(AddressProvider).to receive(:engine_contract_address).and_return(engine_contract_address)
    allow(AddressProvider).to receive(:aius_contract_address).and_return(contract_address)
    allow(standard_arb_erc20_contract).to receive(:new).with(contract_address: contract_address).and_return(mock_contract)
  end

  it 'calls approve on the contract with the correct parameters' do
    expect(mock_contract).to receive(:approve).with(
      from: from_address,
      spender: engine_contract_address,
      amount: 1_000_000 * 10**18
    )
    allow(engine_contract).to receive(:validator_deposit)
    service.call(validator_address: from_address, deposit_amount: 0)
    expect(engine_contract).not_to have_received(:validator_deposit)
  end

  it 'calls validator_deposit if deposit_amount > 0' do
    expect(mock_contract).to receive(:approve).with(
      from: from_address,
      spender: engine_contract_address,
      amount: 1_000_000 * 10**18
    )
    expect(engine_contract).to receive(:validator_deposit).with(
      from: from_address,
      amount: 123,
      context: { class: 'Arbius::SetupService', address: from_address, deposit_amount: 123 }
    )
    service.call(validator_address: from_address, deposit_amount: 123)
  end
end
