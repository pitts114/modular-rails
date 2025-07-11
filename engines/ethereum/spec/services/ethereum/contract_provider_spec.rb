# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::ContractProvider do
  describe '.engine' do
    it 'returns an Eth::Contract::Engine instance' do
      engine = described_class.engine
      expect(engine.name).to eq('Engine')
    end
  end
end
