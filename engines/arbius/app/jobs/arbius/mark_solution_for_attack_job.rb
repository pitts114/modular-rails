require 'json'

module Arbius
  class MarkSolutionForAttackJob < ApplicationJob
    queue_as :arbius_attack_solution

    def perform(task_id)
      Arbius::MarkSolutionForAttackService.new.call(task_id: task_id)
    end
  end
end
