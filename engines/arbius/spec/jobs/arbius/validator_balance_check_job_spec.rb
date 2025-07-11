# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::ValidatorBalanceCheckJob do
  let(:service) { double(:service) }

  describe '#perform' do
    it 'calls the service' do
      expect(service).to receive(:call)
      subject.perform(service: service)
    end
  end
end
