# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethereum::SendTransactionJob, type: :job do
  let(:address) { '0x1234567890abcdef' }
  let(:chain_id) { 1 }
  let(:service) { double(:service) }

  it 'calls SendTransactionService with the given address and chain_id' do
    expect(Ethereum::SendTransactionService).to receive(:new).and_return(service)
    expect(service).to receive(:call).with(address:, chain_id:)
    described_class.perform_now(address, chain_id)
  end
end
