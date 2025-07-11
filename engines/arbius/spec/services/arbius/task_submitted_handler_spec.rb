require 'rails_helper'

RSpec.describe Arbius::TaskSubmittedHandler do
  let(:job_class) { double(:job_class, perform_later: true) }
  let(:payload) { { foo: 'bar', baz: 123 } }
  subject { described_class.new(job: job_class) }

  describe '#call' do
    it 'calls perform_later on the job with the payload as JSON' do
      expect(job_class).to receive(:perform_later).with(payload.to_json)
      subject.call(payload: payload)
    end
  end
end
