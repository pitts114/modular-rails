require 'rails_helper'

RSpec.describe Arbius::AlertOutnumberedJob, type: :job do
  it 'calls Arbius::AlertOutnumberedService' do
    service_double = double('Arbius::AlertOutnumberedService')
    expect(Arbius::AlertOutnumberedService).to receive(:new).and_return(service_double)
    expect(service_double).to receive(:call)
    described_class.new.perform
  end
end
