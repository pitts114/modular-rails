require 'rails_helper'

RSpec.describe Ethereum::EventHandlerJob, type: :job do
  let(:log) do
    {
      blockHash: '0xblock'
    }.to_json
  end
  let(:chain_id) { 1 }

  it 'calls Ethereum::EventHandler with the parsed log' do
    expect(Ethereum::EventHandler)
      .to receive_message_chain(:new, :call)
      .with(chain_id: chain_id, log: an_instance_of(Ethereum::LogEventDto), raw_event: hash_including("blockHash" => "0xblock"))
    described_class.perform_now(log, chain_id)
  end
end
