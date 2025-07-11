require 'rails_helper'

RSpec.describe Arbius::AlertValidatorDepositService do
  let(:pagerduty) { double(:pagerduty, trigger: true) }
  subject(:service) { described_class.new(pagerduty: pagerduty) }

  before do
    allow(Rails).to receive_message_chain(:env, :production?).and_return(is_production)
  end

  context 'when Rails.env.production? is true' do
    let(:is_production) { true }

    it 'triggers pagerduty alert' do
      service.call
      expect(pagerduty).to have_received(:trigger).with(summary: 'Validator deposit alert, stopping auto mining', source: 'acc', severity: 'critical')
    end
  end

  context 'when Rails.env.production? is false' do
    let(:is_production) { false }

    it 'does not trigger pagerduty alert' do
      service.call
      expect(pagerduty).not_to have_received(:trigger)
    end
  end
end
