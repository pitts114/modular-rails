require 'rails_helper'

RSpec.describe Arbius::ValidatorDepositJob, type: :job do
  let(:payload_hash) { { foo: 'bar' } }
  let(:payload_json) { payload_hash.to_json }
  let(:service_double) { double(:validator_deposit_service) }

  before do
    allow(Arbius::ValidatorDepositService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:call)
  end

  it 'parses the payload and calls ValidatorDepositService with the payload' do
    described_class.perform_now(payload_json)
    expect(Arbius::ValidatorDepositService).to have_received(:new)
    expect(service_double).to have_received(:call).with(payload: payload_hash)
  end
end
