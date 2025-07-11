# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arbius::AttackSolutionJob, type: :job do
  let(:task_id) { 42 }
  let(:attack_solution_service) { double(:attack_solution_service) }

  before do
    stub_const('Arbius::AttackSolutionService', Class.new)
    allow(Arbius::AttackSolutionService).to receive(:new).and_return(attack_solution_service)
    allow(attack_solution_service).to receive(:call)
  end

  it 'calls AttackSolutionService with the given task_id' do
    described_class.perform_now(task_id)
    expect(attack_solution_service).to have_received(:call).with(task_id: task_id)
  end
end
