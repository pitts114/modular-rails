require 'rails_helper'

RSpec.describe Arbius::Polling::Poller do
  let(:poller) { described_class.new(max_attempts: 3, interval: 0) }

  it 'returns the result if found immediately' do
    result = poller.poll { 42 }
    expect(result).to eq(42)
  end

  it 'returns the result if found after retries' do
    attempts = 0
    result = poller.poll do
      attempts += 1
      attempts < 3 ? nil : 'found'
    end
    expect(result).to eq('found')
  end

  it 'retries if ActiveRecord::RecordNotFound is raised and succeeds' do
    attempts = 0
    result = poller.poll do
      attempts += 1
      raise ActiveRecord::RecordNotFound if attempts < 3
      'found'
    end
    expect(result).to eq('found')
  end

  it 'raises TimeoutError if not found in time' do
    expect {
      poller.poll { nil }
    }.to raise_error(Arbius::Polling::Poller::TimeoutError)
  end
end
