# frozen_string_literal: true

require 'securerandom'

module Arbius
  class BulkBogusMineService
    def initialize(mine_solution_service: Arbius::BulkMineSolutionService.new)
      @mine_solution_service = mine_solution_service
    end

    # Calls MineSolutionService with a random fake CID
    # @param from [String] Ethereum address submitting the solution
    # @param taskid [String] Task hash (bytes32)
    def call(from:, taskids:)
      cids = taskids.map { '0x' + SecureRandom.hex(32) }
      @mine_solution_service.call(from: from, taskids:, cids:)
    end
  end
end
