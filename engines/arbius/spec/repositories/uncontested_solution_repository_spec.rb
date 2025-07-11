require 'rails_helper'

RSpec.describe Arbius::UncontestedSolutionRepository, type: :model do
  let(:miner) { Arbius::Miner.create!(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045') }
  let(:non_miner) { '0x1111111111111111111111111111111111111111' }
  let(:now) { Time.current }
  let(:old_time) { now - 2.hours }
  let(:recent_time) { now - 5.minutes }

  def create_solution(address:, task:, created_at:)
    if address != non_miner
      Arbius::Miner.find_or_create_by!(address: address)
      details = create(:arbius_ethereum_event_detail)
      Arbius::SolutionSubmittedEvent.create!(address: address, task: task, created_at: created_at, arbius_ethereum_event_details_id: details.id)
    else
      details = create(:arbius_ethereum_event_detail)
      # Do not create SolutionSubmittedEvent for non_miner, as it would fail validation
      nil
    end
  end

  def create_contestation(task:)
    details = create(:arbius_ethereum_event_detail)
    Arbius::ContestationSubmittedEvent.create!(task: task, address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', arbius_ethereum_event_details_id: details.id)
  end

  def create_claimed(task:)
    details = create(:arbius_ethereum_event_detail)
    Arbius::SolutionClaimedEvent.create!(task: task, address: '0xab5801a7d398351b8be11c439e05c5b3259aec9b', arbius_ethereum_event_details_id: details.id)
  end

  before do
    miner # ensure miner exists
  end

  it 'returns only old, uncontested, unclaimed solutions from miners' do
    # Old, uncontested, unclaimed, from miner
    create_solution(address: miner.address, task: 'task1', created_at: old_time)
    # Recent, uncontested, unclaimed, from miner
    create_solution(address: miner.address, task: 'task2', created_at: recent_time)
    # Old, contested, unclaimed, from miner
    create_solution(address: miner.address, task: 'task3', created_at: old_time)
    create_contestation(task: 'task3')
    # Old, uncontested, claimed, from miner
    create_solution(address: miner.address, task: 'task4', created_at: old_time)
    create_claimed(task: 'task4')
    # Old, uncontested, unclaimed, from non-miner
    create_solution(address: non_miner, task: 'task5', created_at: old_time)

    results = described_class.old_uncontested_solutions(older_than: now - 1.hour)
    task_ids = results.map(&:task)

    expect(task_ids).to include('task1')
    expect(task_ids).not_to include('task2')
    expect(task_ids).not_to include('task3')
    expect(task_ids).not_to include('task4')
    expect(task_ids).not_to include('task5')
  end

  it 'respects the limit parameter' do
    # Create multiple old, uncontested, unclaimed solutions
    create_solution(address: miner.address, task: 'task1', created_at: old_time)
    create_solution(address: miner.address, task: 'task2', created_at: old_time)
    create_solution(address: miner.address, task: 'task3', created_at: old_time)

    results = described_class.old_uncontested_solutions(older_than: now - 1.hour, limit: 2)
    expect(results.length).to eq(2)
  end

  it 'returns all results when no limit is specified' do
    # Create multiple old, uncontested, unclaimed solutions
    create_solution(address: miner.address, task: 'task1', created_at: old_time)
    create_solution(address: miner.address, task: 'task2', created_at: old_time)
    create_solution(address: miner.address, task: 'task3', created_at: old_time)

    results = described_class.old_uncontested_solutions(older_than: now - 1.hour)
    expect(results.length).to eq(3)
  end
end
