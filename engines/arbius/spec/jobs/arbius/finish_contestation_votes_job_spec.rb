require 'rails_helper'

RSpec.describe Arbius::FinishContestationVotesJob, type: :job do
  describe '#perform' do
    it 'calls Arbius::FinishContestationVotesService.new.call' do
      service_instance = instance_double(Arbius::FinishContestationVotesService)
      expect(Arbius::FinishContestationVotesService).to receive(:new).and_return(service_instance)
      expect(service_instance).to receive(:call)
      described_class.perform_now
    end
  end
end
