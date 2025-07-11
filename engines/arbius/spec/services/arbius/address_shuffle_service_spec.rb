require 'rails_helper'

RSpec.describe Arbius::AddressShuffleService do
  describe '#shuffle' do
    let(:addresses) { %w[0xA 0xB 0xC 0xD] }
    let(:task_id) { 'task-123' }
    let(:random) { double(:random) }
    let(:service) { described_class.new(random: random) }

    it 'returns a shuffled array of the same addresses' do
      random_instance = double(:random_instance)
      allow(random).to receive(:new).with(task_id.hash).and_return(random_instance)
      allow(addresses).to receive(:shuffle).with(random: random_instance).and_return([ "0xB", "0xA", "0xD", "0xC" ])
      shuffled = service.shuffle(addresses: addresses, task_id: task_id)
      expect(shuffled.sort).to eq(addresses.sort)
      expect(shuffled).not_to eq(addresses) # Most of the time, order will change
    end

    it 'is deterministic for the same task_id' do
      random_instance = double(:random_instance)
      allow(random).to receive(:new).with(task_id.hash).and_return(random_instance)
      allow(addresses).to receive(:shuffle).with(random: random_instance).and_return([ "0xB", "0xA", "0xD", "0xC" ]).twice
      shuffled1 = service.shuffle(addresses: addresses, task_id: task_id)
      shuffled2 = service.shuffle(addresses: addresses, task_id: task_id)
      expect(shuffled1).to eq(shuffled2)
    end

    it 'is different for different task_ids' do
      random_instance1 = double(:random_instance1)
      random_instance2 = double(:random_instance2)
      allow(random).to receive(:new).with('task-1'.hash).and_return(random_instance1)
      allow(random).to receive(:new).with('task-2'.hash).and_return(random_instance2)
      allow(addresses).to receive(:shuffle).with(random: random_instance1).and_return([ "0xB", "0xA", "0xD", "0xC" ])
      allow(addresses).to receive(:shuffle).with(random: random_instance2).and_return([ "0xC", "0xD", "0xA", "0xB" ])
      shuffled1 = service.shuffle(addresses: addresses, task_id: 'task-1')
      shuffled2 = service.shuffle(addresses: addresses, task_id: 'task-2')
      expect(shuffled1).not_to eq(shuffled2)
    end

    it 'can use a custom random class' do
      custom_random = Class.new do
        def initialize(seed); end
        def rand(*); 0.5; end
      end
      service = described_class.new(random: custom_random)
      addresses = %w[0xA 0xB 0xC 0xD]
      shuffled = service.shuffle(addresses: addresses, task_id: task_id)
      expect(shuffled.sort).to eq(addresses.sort)
    end

    it 'calls shuffle with the correct random instance' do
      random_instance = double(:random_instance)
      expect(random).to receive(:new).with(task_id.hash).and_return(random_instance)
      expect(addresses).to receive(:shuffle).with(random: random_instance).and_return([ "0xB", "0xA", "0xD", "0xC" ])
      result = service.shuffle(addresses: addresses, task_id: task_id)
      expect(result).to eq([ "0xB", "0xA", "0xD", "0xC" ])
    end
  end
end
