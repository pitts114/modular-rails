require 'rails_helper'

RSpec.describe Arbius::SolutionSubmittedEventRepository do
  let(:attributes) do
    {
      ethereum_event_id: SecureRandom.uuid,
      block_hash: '0xabc',
      block_number: 1,
      chain_id: 1,
      contract_address: '0xdef',
      transaction_hash: '0x123',
      transaction_index: 0,
      address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      task: 'task-1'
    }
  end

  before do
    Arbius::Miner.create!(address: attributes[:address])
  end

  describe '.save!' do
    it 'creates both an EthereumEventDetail and a SolutionSubmittedEvent' do
      expect {
        described_class.save!(attributes: attributes)
      }.to change(Arbius::EthereumEventDetail, :count).by(1)
       .and change(Arbius::SolutionSubmittedEvent, :count).by(1)
    end

    it 'raises RecordNotUnique if the ethereum_event_id is not unique' do
      described_class.save!(attributes: attributes)
      expect {
        described_class.save!(attributes: attributes)
      }.to raise_error(described_class::RecordNotUnique)
    end

    it 'raises RecordInvalid if required attributes are missing' do
      invalid_attrs = attributes.except(:address)
      expect {
        described_class.save!(attributes: invalid_attrs)
      }.to raise_error(described_class::RecordInvalid)
    end
  end

  describe '.old_contested_solutions' do
    let(:miner) { Arbius::Miner.find_by(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045') }
    let!(:solution_event_detail) { Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x1', block_number: 1, chain_id: 1, contract_address: '0x1', transaction_hash: '0x1', transaction_index: 1) }
    let!(:solution) { Arbius::SolutionSubmittedEvent.create!(address: miner.address, task: 'task-1', arbius_ethereum_event_details_id: solution_event_detail.id, created_at: 4.days.ago) }
    let!(:contestation_event_detail) { Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x2', block_number: 2, chain_id: 1, contract_address: '0x2', transaction_hash: '0x2', transaction_index: 2) }
    let!(:contestation) { Arbius::ContestationSubmittedEvent.create!(address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: 'task-1', arbius_ethereum_event_details_id: contestation_event_detail.id, created_at: 1.day.ago) }

    it 'returns solutions with a related contestation and no contestation vote finish event' do
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).to include(solution)
    end

    it 'does not return solutions without a related contestation' do
      event_detail2 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x3', block_number: 3, chain_id: 1, contract_address: '0x3', transaction_hash: '0x3', transaction_index: 3)
      solution2 = Arbius::SolutionSubmittedEvent.create!(address: miner.address, task: 'task-2', arbius_ethereum_event_details_id: event_detail2.id, created_at: 2.days.ago)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).not_to include(solution2)
    end

    it 'does not return solutions with a contestation vote finish event' do
      event_detail3 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x4', block_number: 4, chain_id: 1, contract_address: '0x4', transaction_hash: '0x4', transaction_index: 4)
      Arbius::ContestationVoteFinishEvent.create!(arbius_ethereum_event_details_id: event_detail3.id, task_id: 'task-1', start_idx: 0, end_idx: 1, created_at: 1.day.ago)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).to be_empty
    end
    it 'does not return solutions where yea votes are greater than nay votes' do
      event_detail4 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x5', block_number: 5, chain_id: 1, contract_address: '0x5', transaction_hash: '0x5', transaction_index: 5)
      # Add two yea votes, one nay vote for task-1
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail4.id, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: 'task-1', yea: true)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail4.id, address: '0x1111111111111111111111111111111111111111', task: 'task-1', yea: true)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail4.id, address: '0x2222222222222222222222222222222222222222', task: 'task-1', yea: false)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).not_to include(solution)
    end
    it 'returns solutions where nay votes are greater than yea votes' do
      event_detail5 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x6', block_number: 6, chain_id: 1, contract_address: '0x6', transaction_hash: '0x6', transaction_index: 6)
      # Add two nay votes, one yea vote for task-1
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail5.id, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: 'task-1', yea: false)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail5.id, address: '0x1111111111111111111111111111111111111111', task: 'task-1', yea: false)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail5.id, address: '0x2222222222222222222222222222222222222222', task: 'task-1', yea: true)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).to include(solution)
    end
    it 'returns solutions where nay votes tie yea votes' do
      event_detail6 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x7', block_number: 7, chain_id: 1, contract_address: '0x7', transaction_hash: '0x7', transaction_index: 7)
      # Add one nay and one yea vote for task-1
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail6.id, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: 'task-1', yea: false)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail6.id, address: '0x1111111111111111111111111111111111111111', task: 'task-1', yea: true)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 0)).to include(solution)
    end

    it 'returns solutions only if they are older than the extension time per vote' do
      event_detail7 = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: '0x8', block_number: 8, chain_id: 1, contract_address: '0x8', transaction_hash: '0x8', transaction_index: 8)
      # Add two votes for task-1
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail7.id, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', task: 'task-1', yea: false)
      Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail7.id, address: '0x1111111111111111111111111111111111111111', task: 'task-1', yea: true)
      # If per_vote_extension_time is 1 day (in seconds), contestation must be older than 1.day.ago - 2.days (i.e., 3.days.ago)
      contestation = Arbius::ContestationSubmittedEvent.find_by(task: 'task-1')
      contestation.update!(created_at: 3.days.ago)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 1.day.to_i)).to include(solution)
      expect(described_class.old_contested_solutions(older_than: 1.day.ago, per_vote_extension_time: 2.days.to_i)).not_to include(solution)
    end
  end

  describe '.unattacked_for_addresses' do
    let(:addresses) do
      [
        '0x1234567890AbcdEF1234567890aBcdef12345678',
        '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
        '0x220866B1A2219f40e72f5c628B65D54268cA3A9D',
        '0x1111111111111111111111111111111111111111',
        '0x2222222222222222222222222222222222222222',
        '0x0F1756227eF240372D77ec66c8FFA2e68c09Dc69',
        '0xC1E75C292c75A71E2F1449950C07203F0f09ADE7',
        '0x4C13157dA14b79910801F7C79D960BE8bc9689b9',
        '0xD4392F2F4E3aD7B000124a4Cd824350167985938',
        '0x6d21f977F9752eBD252972632b7D5CE133D028B3'
      ].map { |addr| Eth::Address.new(addr).checksummed }
    end
    let(:cutoff_time) { 1.hour.ago }

    def create_solution(address:, task:, created_at:)
      event_detail = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: SecureRandom.hex(4), block_number: rand(1..100), chain_id: 1, contract_address: SecureRandom.hex(4), transaction_hash: SecureRandom.hex(4), transaction_index: rand(1..100))
      Arbius::SolutionSubmittedEvent.create!(address: address, task: task, arbius_ethereum_event_details_id: event_detail.id, created_at: created_at)
    end

    it 'returns only unattacked solutions for the given addresses, ordered oldest to newest' do
      s1 = create_solution(address: addresses[0], task: 'task-1', created_at: 10.minutes.ago)
      s2 = create_solution(address: addresses[1], task: 'task-2', created_at: 5.minutes.ago)
      s3 = create_solution(address: addresses[2], task: 'task-3', created_at: 2.minutes.ago)
      # Add an attack solution for s2 (should exclude s2)
      create(:arbius_attack_solution, task: 'task-2')
      # Add a solution for an address not in the list (should not be included)
      create_solution(address: '0x3333333333333333333333333333333333333333', task: 'task-4', created_at: 1.minute.ago)
      test_cutoff_time = 15.minutes.ago
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: test_cutoff_time)
      expect(results).to eq([ s1, s3 ])
    end

    it 'does not return solutions for addresses that are miners' do
      s1 = create_solution(address: addresses[3], task: 'task-5', created_at: 5.hours.ago)
      Arbius::Miner.create!(address: addresses[3])
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: cutoff_time)
      expect(results).not_to include(s1)
    end

    it 'does not return solutions for addresses that are validators' do
      s1 = create_solution(address: addresses[4], task: 'task-6', created_at: 6.hours.ago)
      Arbius::Validator.create!(address: addresses[4])
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: cutoff_time)
      expect(results).not_to include(s1)
    end

    it 'respects the limit argument' do
      s1 = create_solution(address: addresses[5], task: 'task-7', created_at: 10.minutes.ago)
      s2 = create_solution(address: addresses[6], task: 'task-8', created_at: 9.minutes.ago)
      s3 = create_solution(address: addresses[7], task: 'task-9', created_at: 8.minutes.ago)
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 2, cutoff_time: 15.minutes.ago)
      expect(results.size).to eq(2)
      expect(results).to eq([ s1, s2 ])
    end

    it 'returns only solutions created at or after cutoff_time' do
      create_solution(address: addresses[8], task: 'task-10', created_at: 2.hours.ago)
      s2 = create_solution(address: addresses[9], task: 'task-11', created_at: 5.minutes.ago)
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: 1.hour.ago)
      expect(results).to eq([ s2 ])
    end

    it 'returns an empty array if limit is zero or negative' do
      create_solution(address: addresses[0], task: 'task-12', created_at: 3.hours.ago)
      expect(described_class.unattacked_for_addresses(addresses: addresses, limit: 0, cutoff_time: cutoff_time)).to eq([])
      expect(described_class.unattacked_for_addresses(addresses: addresses, limit: -1, cutoff_time: cutoff_time)).to eq([])
    end

    it 'returns an empty array if there are no matching solutions' do
      expect(described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: cutoff_time)).to eq([])
    end

    # Additional edge case: if a solution is attacked after creation, it should not be returned
    it 'does not return solutions that have been attacked after creation' do
      s1 = create_solution(address: addresses[0], task: 'task-13', created_at: 4.hours.ago)
      create(:arbius_attack_solution, task: 'task-13')
      results = described_class.unattacked_for_addresses(addresses: addresses, limit: 10, cutoff_time: cutoff_time)
      expect(results).not_to include(s1)
    end
  end

  describe '.attacked_solutions_with_yea_majority' do
    let(:older_than) { 1.day.ago }
    let(:per_vote_extension_time) { 0 }
    let(:task) { 'task-majority' }
    let(:address) { Eth::Address.new('0xAABBCCDDEEFF0011223344556677889900AABBCC').checksummed }

    def create_solution_with_attack_and_votes(address:, task:, created_at:, yea_count:, nay_count:)
      event_detail = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: SecureRandom.hex(4), block_number: rand(1..100), chain_id: 1, contract_address: SecureRandom.hex(4), transaction_hash: SecureRandom.hex(4), transaction_index: rand(1..100))
      solution = Arbius::SolutionSubmittedEvent.create!(address: address, task: task, arbius_ethereum_event_details_id: event_detail.id, created_at: created_at)
      create(:arbius_attack_solution, task: task)
      contestation = Arbius::ContestationSubmittedEvent.create!(address: address, task: task, arbius_ethereum_event_details_id: event_detail.id, created_at: created_at + 1.minute)
      yea_count.times do |i|
        Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail.id, address: "0x#{'%040d' % i}", task: task, yea: true)
      end
      nay_count.times do |i|
        Arbius::ContestationVoteEvent.create!(arbius_ethereum_event_details_id: event_detail.id, address: "0x#{'%040d' % (i+100)}", task: task, yea: false)
      end
      [ solution, contestation ]
    end

    it 'returns solutions with attack, contestation, no finish event, and more yea than nay votes, older than cutoff' do
      s1, c1 = create_solution_with_attack_and_votes(address: address, task: 'task-majority-1', created_at: 2.days.ago, yea_count: 3, nay_count: 1)
      s2, c2 = create_solution_with_attack_and_votes(address: address, task: 'task-majority-2', created_at: 3.days.ago, yea_count: 2, nay_count: 0)
      c1.update!(created_at: 2.days.ago)
      c2.update!(created_at: 3.days.ago)
      results = described_class.attacked_solutions_with_yea_majority(older_than: older_than, per_vote_extension_time: per_vote_extension_time)
      expect(results).to include(s1, s2)
    end

    it 'does not return solutions where nays tie or exceed yeas' do
      s1, c1 = create_solution_with_attack_and_votes(address: address, task: 'task-tie', created_at: 2.days.ago, yea_count: 2, nay_count: 2)
      s2, c2 = create_solution_with_attack_and_votes(address: address, task: 'task-nay-majority', created_at: 2.days.ago, yea_count: 1, nay_count: 3)
      c1.update!(created_at: 2.days.ago)
      c2.update!(created_at: 2.days.ago)
      results = described_class.attacked_solutions_with_yea_majority(older_than: older_than, per_vote_extension_time: per_vote_extension_time)
      expect(results).not_to include(s1, s2)
    end

    it 'does not return solutions that are not older than the cutoff (with extension)' do
      s1, c1 = create_solution_with_attack_and_votes(address: address, task: 'task-young', created_at: 1.hour.ago, yea_count: 3, nay_count: 1)
      c1.update!(created_at: 1.hour.ago)
      results = described_class.attacked_solutions_with_yea_majority(older_than: older_than, per_vote_extension_time: per_vote_extension_time)
      expect(results).not_to include(s1)
    end

    it 'does not return solutions with a contestation vote finish event' do
      s1, c1 = create_solution_with_attack_and_votes(address: address, task: 'task-finish', created_at: 2.days.ago, yea_count: 3, nay_count: 1)
      c1.update!(created_at: 2.days.ago)
      event_detail = Arbius::EthereumEventDetail.create!(ethereum_event_id: SecureRandom.uuid, block_hash: SecureRandom.hex(4), block_number: rand(1..100), chain_id: 1, contract_address: SecureRandom.hex(4), transaction_hash: SecureRandom.hex(4), transaction_index: rand(1..100))
      Arbius::ContestationVoteFinishEvent.create!(arbius_ethereum_event_details_id: event_detail.id, task_id: 'task-finish', start_idx: 0, end_idx: 1, created_at: 1.day.ago)
      results = described_class.attacked_solutions_with_yea_majority(older_than: older_than, per_vote_extension_time: per_vote_extension_time)
      expect(results).not_to include(s1)
    end

    it 'applies per_vote_extension_time to the cutoff' do
      # 2 votes, extension is 1 day per vote, so must be older than 1.day.ago - 2.days = 3.days.ago
      s1, c1 = create_solution_with_attack_and_votes(address: address, task: 'task-ext', created_at: 4.days.ago, yea_count: 2, nay_count: 1)
      s2, c2 = create_solution_with_attack_and_votes(address: address, task: 'task-ext-young', created_at: 2.days.ago, yea_count: 2, nay_count: 1)
      c1.update!(created_at: 4.days.ago)
      c2.update!(created_at: 2.days.ago)
      results = described_class.attacked_solutions_with_yea_majority(older_than: 1.day.ago, per_vote_extension_time: 1.day.to_i)
      expect(results).to include(s1)
      expect(results).not_to include(s2)
    end
  end
end
