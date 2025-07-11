module Arbius
  class BogusMineJob < ApplicationJob
    queue_as :arbius_bogus_mine

    def perform(from, task_id)
      Arbius::BogusMineService.new.call(from: from, taskid: task_id)
    end
  end
end
