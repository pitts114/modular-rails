require 'rails_helper'

RSpec.describe Arbius::ValidatorDepositHandler do
  let(:job) { double(:validator_deposit_job, perform_later: true) }
  let(:payload) { { foo: 'bar' } }
  subject(:handler) { described_class.new(job: job) }

  it 'enqueues the job with the payload as JSON' do
    handler.call(payload: payload)
    expect(job).to have_received(:perform_later).with(payload.to_json)
  end
end
