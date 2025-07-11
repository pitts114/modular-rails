# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::EthContractCallService do
  let(:eth_client) { double(:eth_client) }
  let(:signer_service) { double(:signer_service) }
  let(:broadcast_service) { double(:broadcast_service) }
  let(:fee_estimator_service) { double(:fee_estimator_service) }
  let(:gas_limit_service) { double(:gas_limit_service) }
  let(:service) do
    described_class.new(
      eth_client: eth_client,
      signer_service: signer_service,
      broadcast_service: broadcast_service,
      fee_estimator_service: fee_estimator_service,
      gas_limit_service: gas_limit_service
    )
  end

  let(:from) { '0xSender' }
  let(:contract_address) { '0xContract' }
  let(:data) { '0xabcdef' }
  let(:value) { 12345 }
  let(:nonce) { 1 }
  let(:chain_id) { 5 }
  let(:fees) { { max_fee_per_gas: 100, max_priority_fee_per_gas: 2 } }
  let(:gas_limit) { 21000 }
  let(:signed_tx) { '0xsignedtx' }
  let(:tx_hash) { '0xtxhash' }

  before do
    allow(eth_client).to receive(:eth_get_transaction_count).with(from, "pending").and_return({ "result" => nonce.to_s(16) })
    allow(eth_client).to receive(:chain_id).and_return(chain_id)
    allow(fee_estimator_service).to receive(:recommended_fees).and_return(fees)
    allow(gas_limit_service).to receive(:for_contract_call).with(chain_id: chain_id, from: from, to: contract_address, data: data, value: value).and_return(gas_limit)
    allow(signer_service).to receive(:sign_transaction).and_return(signed_tx)
    allow(broadcast_service).to receive(:send_transaction).with(signed_tx: signed_tx).and_return(tx_hash)
  end

  it 'calls a contract and broadcasts the transaction' do
    result = service.call_contract(contract_address: contract_address, from: from, data: data, value: value)
    expect(result).to eq(tx_hash)
    expect(gas_limit_service).to have_received(:for_contract_call).with(chain_id: chain_id, from: from, to: contract_address, data: data, value: value)
    expect(signer_service).to have_received(:sign_transaction)
    expect(broadcast_service).to have_received(:send_transaction).with(signed_tx: signed_tx)
  end

  it 'raises an error if something fails' do
    allow(eth_client).to receive(:eth_get_transaction_count).with(from, "pending").and_raise(StandardError, 'fail')
    expect {
      service.call_contract(contract_address: contract_address, from: from, data: data, value: value)
    }.to raise_error(Ethereum::EthContractCallService::Error, /Failed to call contract/)
  end
end
