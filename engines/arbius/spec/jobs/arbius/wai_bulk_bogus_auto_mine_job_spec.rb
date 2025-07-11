require 'rails_helper'

RSpec.describe Arbius::WaiBulkBogusAutoMineJob, type: :job do
  let(:service_double) { double(:bulk_bogus_auto_mine_service) }
  let(:miner_double) { double(:miner, address: '0xe61fc6257160fCbe27cd81E95e3AE5A1835e451A') }

  before do
    stub_const('ENV', ENV.to_hash.merge('ARBIUS_BULK_BOGUS_AUTO_MINE_N' => '42'))
    allow(Arbius::Miner).to receive_message_chain(:first).and_return(miner_double)
    allow(Arbius::BulkBogusAutoMineService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:call)
  end

  it 'calls BulkBogusAutoMineService with correct arguments from the first miner and env n' do
    expect(Arbius::BulkBogusAutoMineService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call).with(
      from: miner_double.address,
      model: '0xa473c70e9d7c872ac948d20546bc79db55fa64ca325a4b229aaffddb7f86aae0',
      fee: Arbius::ModelFees::WAI_FEE,
      input: { prompt: 'I will protect honest miners. I will destroy dishonest miners.' },
      n: 42
    )
    described_class.perform_now
  end
end
