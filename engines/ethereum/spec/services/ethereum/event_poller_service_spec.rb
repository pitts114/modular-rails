# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::EventPollerService do
  let(:logger) { instance_double(Logger, info: nil) }
  let(:poller_name) { 'event_poller' }
  let(:poll_interval) { 1 }
  let(:batch_size) { 100 }
  let(:chain_id) { 123 }
  let(:engine_contract) { instance_double('Eth::Contract', abi: 'abi') }
  let(:event_poller_state_model) { class_double('Ethereum::EventPollerState') }
  let(:default_start_block) { 42 }
  let(:client) { instance_double('Ethereum::Client', chain_id: chain_id) }
  let(:event_handler_job) { class_double('Ethereum::EventHandlerJob', perform_later: true) }
  let(:eth_event_utils) { class_double('EthEventUtils', topic0_for: 'topic0') }
  let(:event_poller_instance) { instance_double('Ethereum::EventPoller', run: nil) }
  let(:event_poller_class) { class_double('Ethereum::EventPoller', new: event_poller_instance) }

  subject(:service) do
    described_class.new(
      logger: logger,
      poller_name: poller_name,
      poll_interval: poll_interval,
      batch_size: batch_size,
      engine_contract: engine_contract,
      event_poller_state_model: event_poller_state_model,
      default_start_block: default_start_block,
      client: client,
      event_handler_job: event_handler_job,
      eth_event_utils: eth_event_utils,
      event_poller_class: event_poller_class
    )
  end

  describe '#call' do
    it 'builds event_name_to_topic0 correctly and starts the poller' do
      allow(event_poller_state_model).to receive(:find_by).with(poller_name: poller_name).and_return(nil)
      expect(event_poller_class).to receive(:new).with(
        client: client,
        contracts: [ engine_contract ],
        event_name_to_topic0: { engine_contract => described_class::ENGINE_EVENT_NAMES.map { |name| [ name, 'topic0' ] }.to_h },
        start_block: default_start_block,
        poll_interval: poll_interval,
        chain_id: chain_id,
        batch_size: batch_size,
        logger: logger
      ).and_return(event_poller_instance)
      expect(logger).to receive(:info).with(/Starting Arbius event poller/)
      expect(event_poller_instance).to receive(:run)
      service.call
    end

    it 'handles :log and :last_processed_block events from the poller' do
      allow(event_poller_state_model).to receive(:find_by).with(poller_name: poller_name).and_return(nil)
      allow(event_poller_class).to receive(:new).and_return(event_poller_instance)
      expect(logger).to receive(:info).with(/Starting Arbius event poller/)
      # Simulate poller.run yielding events
      allow(event_poller_instance).to receive(:run).and_yield(:log, { foo: 'bar' }).and_yield(:last_processed_block, 99)
      state = double('EventPollerState', last_processed_block: 42)
      allow(event_poller_state_model).to receive(:find_or_initialize_by).with(poller_name: poller_name).and_return(state)
      expect(event_handler_job).to receive(:perform_later).with({ foo: 'bar' }.to_json, chain_id)
      expect(state).to receive(:last_processed_block).and_return(42)
      expect(state).to receive(:last_processed_block=).with(99)
      expect(state).to receive(:save!)
      expect(logger).to receive(:info).with(/Processed up to block: 99/)
      service.call
    end
  end
end
