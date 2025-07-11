require 'rails_helper'

RSpec.describe Arbius::MinerContestationVoteCheckRepository, type: :model do
  describe '.update_checks!' do
    let(:now) { Time.current }
    let!(:event_detail1) { create(:arbius_ethereum_event_detail) }
    let!(:event_detail2) { create(:arbius_ethereum_event_detail) }
    let!(:event_detail3) { create(:arbius_ethereum_event_detail) }
    let!(:old_event) do
      Arbius::ContestationSubmittedEvent.create!(
        arbius_ethereum_event_details_id: event_detail1.id,
        address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
        task: 'task_old',
        created_at: now - 2.minutes
      )
    end
    let!(:recent_event) do
      Arbius::ContestationSubmittedEvent.create!(
        arbius_ethereum_event_details_id: event_detail2.id,
        address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b',
        task: 'task_recent',
        created_at: now - 10.seconds
      )
    end
    let!(:existing_check) do
      Arbius::MinerContestationVoteCheck.create!(
        task_id: 'task_existing',
        created_at: now - 3.minutes
      )
    end
    let!(:event_with_check) do
      Arbius::ContestationSubmittedEvent.create!(
        arbius_ethereum_event_details_id: event_detail3.id,
        address: '0x1111111111111111111111111111111111111111',
        task: 'task_existing',
        created_at: now - 3.minutes
      )
    end

    it 'creates checks for contestation events older than the given seconds and not already checked' do
      result = described_class.update_checks!(seconds: 60)
      expect(result).to include('task_old')
      expect(result).not_to include('task_recent')
      expect(result).not_to include('task_existing')
      expect(Arbius::MinerContestationVoteCheck.where(task_id: 'task_old')).to exist
      expect(Arbius::MinerContestationVoteCheck.where(task_id: 'task_recent')).not_to exist
    end

    it 'does not create duplicate checks' do
      described_class.update_checks!(seconds: 60)
      expect {
        described_class.update_checks!(seconds: 60)
      }.not_to change { Arbius::MinerContestationVoteCheck.count }
    end
  end
end
