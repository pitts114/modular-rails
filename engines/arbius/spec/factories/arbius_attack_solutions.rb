# frozen_string_literal: true

FactoryBot.define do
  factory :arbius_attack_solution, class: 'Arbius::AttackSolution' do
    task { 'task_1' }
  end
end
