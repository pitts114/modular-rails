require 'rails_helper'

RSpec.describe Arbius::AlertOutnumberedService do
  let(:pagerduty) { double(:pagerduty) }

  subject { described_class.new(pagerduty: pagerduty) }

  describe '#call' do
    it 'triggers a Pagerduty alert with correct parameters' do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(pagerduty).to receive(:trigger).with(
        summary: 'Outnumbered in Contestation',
        source: 'acc',
        severity: 'critical'
      )
      subject.call
    end

    it 'does nothing if not in production environment' do
      allow(Rails.env).to receive(:production?).and_return(false)
      expect(pagerduty).not_to receive(:trigger)
      subject.call
    end
  end
end
