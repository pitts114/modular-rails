require 'rails_helper'

RSpec.describe Arbius::ContestationSubmittedJob, type: :job do
  let(:payload_hash) { { foo: 'bar', baz: 123 } }
  let(:payload_json) { payload_hash.to_json }
  let(:service) { instance_double(Arbius::ContestationSubmittedService) }

  before do
    allow(Arbius::ContestationSubmittedService).to receive(:new).and_return(service)
  end

  it 'parses the payload and calls the service' do
    expect(service).to receive(:call).with(payload: payload_hash)
    described_class.new.perform(payload_json)
  end
end
