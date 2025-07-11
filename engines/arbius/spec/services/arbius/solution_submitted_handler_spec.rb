require 'rails_helper'

RSpec.describe Arbius::SolutionSubmittedHandler do
  let(:job) { class_double(Arbius::SolutionSubmittedJob) }
  let(:high_priority_job) { class_double(Arbius::HighPrioritySolutionSubmittedJob) }
  let(:miner_model) { class_double(Arbius::Miner) }
  let(:handler) { described_class.new(job: job, high_priority_job: high_priority_job, miner_model: miner_model) }
  let(:payload) { { address: '0x123', foo: 'bar', baz: 123 } }

  context 'when the address exists in miners' do
    it 'enqueues the high priority job with the payload as JSON' do
      allow(miner_model).to receive(:exists?).with(address: payload[:address]).and_return(true)
      expect(high_priority_job).to receive(:perform_later).with(payload.to_json)
      expect(job).not_to receive(:perform_later)
      handler.call(payload: payload)
    end
  end

  context 'when the address does not exist in miners' do
    it 'enqueues the normal job with the payload as JSON' do
      allow(miner_model).to receive(:exists?).with(address: payload[:address]).and_return(false)
      expect(job).to receive(:perform_later).with(payload.to_json)
      expect(high_priority_job).not_to receive(:perform_later)
      handler.call(payload: payload)
    end
  end
end
