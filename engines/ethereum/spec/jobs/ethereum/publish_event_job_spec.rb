require 'rails_helper'

RSpec.describe Ethereum::PublishEventJob, type: :job do
  let(:ethereum_event_id) { 42 }

  it 'calls the PublishEventService with the given ethereum_event_id' do
    service = instance_double(Ethereum::PublishEventService)
    expect(Ethereum::PublishEventService).to receive(:new).and_return(service)
    expect(service).to receive(:call).with(ethereum_event_id: ethereum_event_id)
    described_class.perform_now(ethereum_event_id)
  end
end
