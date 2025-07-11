module Admin
  class HomeController < ApplicationController
    def index
      @solutions = Arbius::Public::SolutionsService.new.solutions(limit: 10)
      @miners = Arbius::Public::MinersService.new.miners
      @validators = Arbius::Public::ValidatorsService.new.validators
      @arbitrum_block_explorer = ENV.fetch("ARBITRUM_BLOCK_EXPLORER")
      @latest_block_number = Ethereum::Public::LatestBlockNumberService.new.call
    end
  end
end
