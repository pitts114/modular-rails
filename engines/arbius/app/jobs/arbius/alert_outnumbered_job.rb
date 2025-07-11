module Arbius
  class AlertOutnumberedJob < ApplicationJob
    queue_as :default

    def perform
      Arbius::AlertOutnumberedService.new.call
    end
  end
end
