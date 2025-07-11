require 'rails_helper'

RSpec.describe Arbius::SolutionClaimedJob, type: :job do
  let(:payload_hash) { { foo: 'bar', baz: 123 } }
  let(:payload_json) { payload_hash.to_json }
  let(:service) { instance_double(Arbius::SolutionClaimedService) }

  before do
    allow(Arbius::SolutionClaimedService).to receive(:new).and_return(service)
  end

  it 'parses the payload and calls the service' do
    expect(service).to receive(:call).with(payload: payload_hash)
    described_class.new.perform(payload_json)
  end
end
