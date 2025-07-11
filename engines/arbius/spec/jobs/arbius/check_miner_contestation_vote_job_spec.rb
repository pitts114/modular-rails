require 'rails_helper'

RSpec.describe Arbius::CheckMinerContestationVoteJob, type: :job do
  let(:service) { double(:check_miner_contestation_vote_service) }

  before do
    stub_const('Arbius::CheckMinerContestationVoteService', class_double('Arbius::CheckMinerContestationVoteService').as_stubbed_const)
    allow(Arbius::CheckMinerContestationVoteService).to receive(:new).and_return(service)
  end

  it 'calls CheckMinerContestationVoteService#call' do
    expect(service).to receive(:call)
    described_class.new.perform
  end
end
