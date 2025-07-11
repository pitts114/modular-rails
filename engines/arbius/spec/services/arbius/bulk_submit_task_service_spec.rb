# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkSubmitTaskService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:mock_serialize_service) { double(:serialize_service) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract, serialize_service: mock_serialize_service) }

  it 'serializes input and calls engine_contract.submit_task with correct arguments and context' do
    from = '0xabc'
    version = 1
    owner = '0xdef'
    model = '0xfeedfacefeedfacefeedfacefeedfacefeedfacefeedfacefeedfacefeedface'
    fee = 42
    input = { foo: 'bar' }
    n = 3
    input_hex = '0xdeadbeef'
    tx_id = 123
    expected_context = {
      class: 'Arbius::BulkSubmitTaskService',
      from: from,
      version: version,
      owner: owner,
      model: model,
      fee: fee,
      n: n,
      input: input_hex
    }
    expect(mock_serialize_service).to receive(:serialize_hash_to_hex).with(hash: input).and_return(input_hex)
    expect(mock_engine_contract).to receive(:bulk_submit_task).with(
      from: from,
      version: version,
      owner: owner,
      model: model,
      fee: fee,
      n: n,
      input: input_hex,
      context: expected_context
    ).and_return(tx_id)
    result = service.submit_task(from: from, version: version, owner: owner, model: model, fee: fee, input: input, n: n)
    expect(result).to eq(tx_id)
  end
end
