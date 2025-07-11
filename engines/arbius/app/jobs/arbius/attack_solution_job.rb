module Arbius
  class AttackSolutionJob < ApplicationJob
    queue_as :arbius_attack_solution

    def perform(task_id)
      Arbius::AttackSolutionService.new.call(task_id:)
    end
  end
end
