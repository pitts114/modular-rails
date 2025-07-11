module Arbius
  class BulkBogusMineJob < ApplicationJob
    queue_as :arbius_bogus_mine

    def perform(from, task_ids)
      Arbius::BulkBogusMineService.new.call(from: from, taskids: task_ids)
    end
  end
end
