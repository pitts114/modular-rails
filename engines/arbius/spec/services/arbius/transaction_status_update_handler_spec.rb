require 'rails_helper'

RSpec.describe Arbius::TransactionStatusUpdateHandler do
  let(:job) { double(:job, perform_later: nil) }
  let(:handler) { described_class.new(job: job) }
  let(:payload) { { foo: 'bar', baz: 1 } }

  it 'enqueues the job with the payload as JSON' do
    expect(job).to receive(:perform_later).with(payload.to_json)
    handler.call(payload: payload)
  end
end
