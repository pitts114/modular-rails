require 'rails_helper'

RSpec.describe Arbius::SubmitTaskService do
  let(:mock_engine_contract) { double(:engine_contract) }
  let(:mock_serialize_service) { double(:serialize_service) }
  let(:service) { described_class.new(engine_contract: mock_engine_contract, serialize_service: mock_serialize_service) }

  describe '#submit_task' do
    it 'serializes input and calls engine_contract.submit_task with correct args' do
      from = '0xabc'
      version = 1
      owner = '0xdef'
      model = '0x123'
      fee = 1000
      input = { 'foo' => 'bar' }
      input_hex = '0xdeadbeef'
      expected_context = { class: 'Arbius::SubmitTaskService', from: from, version: version, owner: owner, model: model, fee: fee, input: input_hex }

      expect(mock_serialize_service).to receive(:serialize_hash_to_hex).with(hash: input).and_return(input_hex)
      expect(mock_engine_contract).to receive(:submit_task).with(
        from: from,
        version: version,
        owner: owner,
        model: model,
        fee: fee,
        input: input_hex,
        context: expected_context
      )

      service.submit_task(from: from, version: version, owner: owner, model: model, fee: fee, input: input)
    end
  end
end
