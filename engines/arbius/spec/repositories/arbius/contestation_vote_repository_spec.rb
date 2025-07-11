require 'rails_helper'

RSpec.describe Arbius::ContestationVoteRepository do
  let(:task_id) { 'task-1' }

  before do
    # Create event detail for association
    event_detail = create(:arbius_ethereum_event_detail)
    # Create vote events
    Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail.id, address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', task: task_id, yea: true)
    Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail.id, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: task_id, yea: false)
    # Create sent contestation votes
    Arbius::SentContestationVoteEvent.create!(address: '0x1111111111111111111111111111111111111111', task: task_id, yea: true, status: 'confirmed')
    Arbius::SentContestationVoteEvent.create!(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', task: task_id, yea: false, status: 'confirmed') # Should be ignored due to priority
  end

  describe '.votes_for_task' do
    it 'returns a hash of validator_address => vote for the given task' do
      result = described_class.votes_for_task(task_id: task_id)
      expect(result).to eq([
        [ '0x1111111111111111111111111111111111111111', true ],
        [ '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B', false ],
        [ '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', true ]
      ])
    end

    it 'excludes failed sent contestation votes' do
      # Create a failed vote
      Arbius::SentContestationVoteEvent.create!(address: '0x2222222222222222222222222222222222222222', task: task_id, yea: false, status: 'failed')

      result = described_class.votes_for_task(task_id: task_id)
      expect(result).to eq([
        [ '0x1111111111111111111111111111111111111111', true ],
        [ '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B', false ],
        [ '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', true ]
      ])
    end

    it 'includes pending sent contestation votes' do
      # Create a pending vote
      Arbius::SentContestationVoteEvent.create!(address: '0x3333333333333333333333333333333333333333', task: task_id, yea: false, status: 'pending')

      result = described_class.votes_for_task(task_id: task_id)
      expect(result).to eq([
        [ '0x1111111111111111111111111111111111111111', true ],
        [ '0x3333333333333333333333333333333333333333', false ],
        [ '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B', false ],
        [ '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', true ]
      ])
    end
  end
end
