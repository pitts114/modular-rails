module Arbius
  class BulkClaimUncontestedSolutionsJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::BulkClaimUncontestedSolutionsService.new.call
    end
  end
end
