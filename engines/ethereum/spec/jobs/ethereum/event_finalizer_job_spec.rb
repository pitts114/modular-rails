require 'rails_helper'

RSpec.describe Ethereum::EventFinalizerJob, type: :job do
  it 'calls Ethereum::EventFinalizerService' do
    service = class_double(Ethereum::EventFinalizerService).as_stubbed_const
    expect(service).to receive_message_chain(:new, :call)
    described_class.perform_now
  end
end
