require 'rails_helper'

RSpec.describe Arbius::AttackSolution, type: :model do
  subject { described_class.new(task: 'task1') }

  it 'is invalid without task' do
    subject.task = nil
    expect(subject).not_to be_valid
  end
end
