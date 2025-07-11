# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkBogusMineJob, type: :job do
  let(:from) { '0xabc' }
  let(:task_ids) { [
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
  ] }

  it 'calls BulkBogusMineService with the correct arguments' do
    service_double = instance_double(Arbius::BulkBogusMineService)
    expect(Arbius::BulkBogusMineService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call).with(from: from, taskids: task_ids)
    described_class.perform_now(from, task_ids)
  end
end
