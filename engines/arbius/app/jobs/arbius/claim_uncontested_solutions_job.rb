module Arbius
  class ClaimUncontestedSolutionsJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::ClaimUncontestedSolutionsService.new.call
    end
  end
end
