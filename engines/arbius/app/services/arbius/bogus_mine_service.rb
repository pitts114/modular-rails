# frozen_string_literal: true

require 'securerandom'

module Arbius
  class BogusMineService
    def initialize(mine_solution_service: Arbius::MineSolutionService.new)
      @mine_solution_service = mine_solution_service
    end

    # Calls MineSolutionService with a random fake CID
    # @param from [String] Ethereum address submitting the solution
    # @param taskid [String] Task hash (bytes32)
    def call(from:, taskid:, cid: '0x' + SecureRandom.hex(32))
      # Generate a random 32-byte hex string as a fake CID
      @mine_solution_service.call(from: from, taskid: taskid, cid: cid)
    end
  end
end
