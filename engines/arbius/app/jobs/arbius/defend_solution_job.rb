module Arbius
  class DefendSolutionJob < ApplicationJob
    queue_as :arbius_defend_solution

    def perform(task_id)
      Arbius::DefendSolutionService.new.call(task_id:)
    end
  end
end
