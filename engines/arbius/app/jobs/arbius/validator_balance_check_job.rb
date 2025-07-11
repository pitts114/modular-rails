# frozen_string_literal: true

module Arbius
  class ValidatorBalanceCheckJob < ApplicationJob
    queue_as :default

    def perform(
      service: Arbius::ValidatorBalanceCheckService.new
    )
      service.call
    end
  end
end
