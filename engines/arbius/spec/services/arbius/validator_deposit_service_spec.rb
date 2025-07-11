require 'rails_helper'

RSpec.describe Arbius::ValidatorDepositService do
  let(:shutdown_auto_mine_service) { double(:shutdown_auto_mine_service) }
  let(:alert_validator_deposit_service) { double(:alert_validator_deposit_service) }
  let(:flipper) { double(:flipper) }
  let(:payload) { { amount: 20 } }

  before do
    allow(shutdown_auto_mine_service).to receive(:call)
    allow(alert_validator_deposit_service).to receive(:call)
    allow(flipper).to receive(:enabled?).with(:shutdown_on_validator_deposit).and_return(true)
  end

  subject(:service) do
    described_class.new(
      shutdown_auto_mine_service: shutdown_auto_mine_service,
      alert_validator_deposit_service: alert_validator_deposit_service,
      flipper: flipper
    )
  end

  context 'when feature flag is enabled' do
    before do
      allow(flipper).to receive(:enabled?).with(:shutdown_on_validator_deposit).and_return(true)
    end

    context 'when amount is above the minimum threshold' do
      before do
        stub_const('ENV', ENV.to_hash.merge('ARBIUS_VALIDATOR_DEPOSIT_ALERT_MINIMUM_WEI' => '10'))
      end

      it 'calls shutdown_auto_mine_service and alert_validator_deposit_service' do
        service.call(payload: payload)
        expect(shutdown_auto_mine_service).to have_received(:call)
        expect(alert_validator_deposit_service).to have_received(:call)
      end
    end

    context 'when amount is missing' do
      let(:payload) { {} }

      it 'does not call any services' do
        service.call(payload: payload)
        expect(shutdown_auto_mine_service).not_to have_received(:call)
        expect(alert_validator_deposit_service).not_to have_received(:call)
      end
    end

    context 'when amount is below the minimum threshold' do
      let(:payload) { { amount: 1 } }

      it 'does not call any services' do
        service.call(payload: payload)
        expect(shutdown_auto_mine_service).not_to have_received(:call)
        expect(alert_validator_deposit_service).not_to have_received(:call)
      end
    end

    context 'when amount is exactly at the minimum threshold' do
      let(:min_wei) { 10 * Eth::Unit::ETHER.to_i }
      let(:payload) { { amount: min_wei } }

      it 'calls shutdown_auto_mine_service and alert_validator_deposit_service' do
        service.call(payload: payload)
        expect(shutdown_auto_mine_service).to have_received(:call)
        expect(alert_validator_deposit_service).to have_received(:call)
      end
    end

    context 'when ARBIUS_VALIDATOR_DEPOSIT_ALERT_MINIMUM_WEI is set' do
      let(:custom_min) { 123 }
      let(:payload) { { amount: custom_min } }

      before do
        stub_const('ENV', ENV.to_hash.merge('ARBIUS_VALIDATOR_DEPOSIT_ALERT_MINIMUM_WEI' => custom_min.to_s))
      end

      it 'calls shutdown_auto_mine_service and alert_validator_deposit_service at custom threshold' do
        service.call(payload: payload)
        expect(shutdown_auto_mine_service).to have_received(:call)
        expect(alert_validator_deposit_service).to have_received(:call)
      end

      it 'does not call services if below custom threshold' do
        service.call(payload: { amount: custom_min - 1 })
        expect(shutdown_auto_mine_service).not_to have_received(:call)
        expect(alert_validator_deposit_service).not_to have_received(:call)
      end
    end
  end

  context 'when feature flag is disabled' do
    before do
      allow(flipper).to receive(:enabled?).with(:shutdown_on_validator_deposit).and_return(false)
    end

    it 'does not call any services even if amount is above threshold' do
      service.call(payload: payload)
      expect(shutdown_auto_mine_service).not_to have_received(:call)
      expect(alert_validator_deposit_service).not_to have_received(:call)
    end
  end
end
