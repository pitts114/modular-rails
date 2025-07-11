require 'rails_helper'

RSpec.describe Arbius::ClaimUncontestedSolutionsJob, type: :job do
  it 'calls the ClaimUncontestedSolutionsService' do
    service = double(:claim_uncontested_solutions_service)
    expect(Arbius::ClaimUncontestedSolutionsService).to receive(:new).and_return(service)
    expect(service).to receive(:call)
    described_class.new.perform
  end
end
