require 'rails_helper'

RSpec.describe Arbius::HighPrioritySolutionSubmittedJob, type: :job do
  let(:payload_hash) { { foo: 'bar', baz: 123 } }
  let(:payload_json) { payload_hash.to_json }
  let(:service) { instance_double(Arbius::SolutionSubmittedService) }

  before do
    allow(Arbius::SolutionSubmittedService).to receive(:new).and_return(service)
  end

  it 'parses the payload and calls the service' do
    expect(service).to receive(:call).with(payload: payload_hash)
    described_class.new.perform(payload_json)
  end

  it 'is enqueued to the arbius_event_handler_high_priority queue' do
    expect(described_class.queue_name).to eq('arbius_event_handler_high_priority')
  end
end
