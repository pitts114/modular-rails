require 'rails_helper'

RSpec.describe Arbius::TaskSubmittedJob, type: :job do
  let(:payload_hash) { { foo: 'bar', baz: 123 } }
  let(:payload_json) { payload_hash.to_json }

  it 'parses the payload and calls TaskSubmittedEventService with symbolized keys' do
    expect(Arbius::TaskSubmittedService).to receive_message_chain(:new, :call).with(payload: payload_hash)
    described_class.perform_now(payload_json)
  end
end
