# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::BulkClaimUncontestedSolutionsJob, type: :job do
  it 'calls BulkClaimUncontestedSolutionsService' do
    service_double = instance_double(Arbius::BulkClaimUncontestedSolutionsService)
    expect(Arbius::BulkClaimUncontestedSolutionsService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call)
    described_class.perform_now
  end
end
