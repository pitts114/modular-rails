require 'rails_helper'

RSpec.describe Arbius::TransactionStatusUpdateJob, type: :job do
  let(:payload_hash) { { foo: 'bar', baz: 1 } }
  let(:payload_json) { payload_hash.to_json }
  let(:service_double) { double(:transaction_status_update_service) }

  before do
    allow(Arbius::TransactionStatusUpdateService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:call)
  end

  it 'parses the payload and calls the service with symbolized keys' do
    expect(Arbius::TransactionStatusUpdateService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call).with(payload: hash_including(foo: 'bar', baz: 1))
    described_class.perform_now(payload_json)
  end
end
