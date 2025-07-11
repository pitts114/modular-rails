# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::ValidatorBalanceCheckService do
  let(:engine_contract) { double(:engine_contract) }
  let(:validator_model) { double(:validator_model) }
  let(:miner_model) { double(:miner_model) }
  let(:sentry) { double(:sentry) }
  let(:logger) { double(:logger, info: nil, warn: nil, error: nil) }
  let(:validator_minimum) { 1000 }
  let(:threshold) { 1030 } # 103% of 1000

  subject do
    described_class.new(
      engine_contract: engine_contract,
      validator_model: validator_model,
      miner_model: miner_model,
      sentry: sentry,
      logger: logger
    )
  end

  describe '#call' do
    let(:validator) { double(:validator, address: '0xvalidator') }
    let(:miner) { double(:miner, address: '0xminer') }

    before do
      allow(engine_contract).to receive(:get_validator_minimum).and_return(validator_minimum)
      allow(validator_model).to receive(:find_each).and_yield(validator)
      allow(miner_model).to receive(:find_each).and_yield(miner)
    end

    context 'when validator minimum is zero' do
      it 'returns early without checking balances' do
        allow(engine_contract).to receive(:get_validator_minimum).and_return(0)
        expect(engine_contract).not_to receive(:get_validator_deposit)
        expect(sentry).not_to receive(:capture_message)
        expect(logger).to receive(:info).with("Validator minimum: 0")
        subject.call
      end
    end

    context 'when deposits are above threshold' do
      it 'does not report to sentry and logs info' do
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_return(1100)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(1200)
        expect(sentry).not_to receive(:capture_message)
        expect(logger).to receive(:info).with("Validator minimum: 1000")
        expect(logger).to receive(:info).with("Threshold for deposits: 1030")
        expect(logger).to receive(:info).with("Checking validator address=0xvalidator, deposit=1100, threshold=1030")
        expect(logger).to receive(:info).with("Validator (0xvalidator) deposit (1100) meets threshold (1030)")
        expect(logger).to receive(:info).with("Checking miner address=0xminer, deposit=1200, threshold=1030")
        expect(logger).to receive(:info).with("Miner (0xminer) deposit (1200) meets threshold (1030)")
        subject.call
      end
    end

    context 'when deposit is nil' do
      it 'does not report to sentry but logs check' do
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_return(nil)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(1200)
        expect(sentry).not_to receive(:capture_message)
        expect(logger).to receive(:info).with("Checking validator address=0xvalidator, deposit=, threshold=1030")
        expect(logger).to receive(:info).with("Checking miner address=0xminer, deposit=1200, threshold=1030")
        expect(logger).to receive(:info).with("Miner (0xminer) deposit (1200) meets threshold (1030)")
        subject.call
      end
    end

    context 'when validator deposit is below threshold' do
      it 'reports to sentry and logs warning' do
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_return(900)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(1100)
        expect(sentry).to receive(:capture_message).with(
          'Validator deposit below threshold',
          extra: {
            address: '0xvalidator',
            current_deposit: 900,
            threshold: threshold,
            type: 'validator'
          },
          level: :warning
        )
        expect(logger).to receive(:warn).with("Validator (0xvalidator) deposit (900) is below threshold (1030)")
        expect(logger).to receive(:info).with("Miner (0xminer) deposit (1100) meets threshold (1030)")
        subject.call
      end
    end

    context 'when miner deposit is below threshold' do
      it 'reports to sentry and logs warning' do
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_return(1100)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(800)
        expect(sentry).to receive(:capture_message).with(
          'Miner deposit below threshold',
          extra: {
            address: '0xminer',
            current_deposit: 800,
            threshold: threshold,
            type: 'miner'
          },
          level: :warning
        )
        expect(logger).to receive(:warn).with("Miner (0xminer) deposit (800) is below threshold (1030)")
        expect(logger).to receive(:info).with("Validator (0xvalidator) deposit (1100) meets threshold (1030)")
        subject.call
      end
    end

    context 'when both validator and miner deposits are below threshold' do
      it 'reports both to sentry and logs warnings' do
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_return(900)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(800)
        expect(sentry).to receive(:capture_message).with(
          'Validator deposit below threshold',
          extra: {
            address: '0xvalidator',
            current_deposit: 900,
            threshold: threshold,
            type: 'validator'
          },
          level: :warning
        )
        expect(sentry).to receive(:capture_message).with(
          'Miner deposit below threshold',
          extra: {
            address: '0xminer',
            current_deposit: 800,
            threshold: threshold,
            type: 'miner'
          },
          level: :warning
        )
        expect(logger).to receive(:warn).with("Validator (0xvalidator) deposit (900) is below threshold (1030)")
        expect(logger).to receive(:warn).with("Miner (0xminer) deposit (800) is below threshold (1030)")
        subject.call
      end
    end

    context 'when contract call fails' do
      it 'captures exception, logs error, and re-raises' do
        error = StandardError.new('Contract call failed')
        allow(engine_contract).to receive(:get_validator_minimum).and_raise(error)
        expect(sentry).to receive(:capture_exception).with(error, extra: { service: 'ValidatorBalanceCheckService' })
        expect(logger).to receive(:error).with("Exception in ValidatorBalanceCheckService: StandardError: Contract call failed")
        expect { subject.call }.to raise_error(StandardError, 'Contract call failed')
      end
    end

    context 'when individual address check fails' do
      it 'captures exception, logs error, and continues processing' do
        error = StandardError.new('Address check failed')
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xvalidator').and_raise(error)
        allow(engine_contract).to receive(:get_validator_deposit).with(address: '0xminer').and_return(1100)
        expect(sentry).to receive(:capture_exception).with(error, extra: {
          service: 'ValidatorBalanceCheckService',
          address: '0xvalidator',
          type: 'validator'
        })
        expect(logger).to receive(:error).with("Exception checking validator (0xvalidator): StandardError: Address check failed")
        expect(logger).to receive(:info).with("Miner (0xminer) deposit (1100) meets threshold (1030)")
        expect(sentry).not_to receive(:capture_message)
        subject.call
      end
    end
  end
end
