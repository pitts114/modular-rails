module Admin
  class SolutionsController < ApplicationController
    def index
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = 50
      offset = (page - 1) * per_page
      @solutions = Arbius::Public::SolutionsService.new.solutions(limit: per_page, offset: offset)
      @total_count = Arbius::SolutionSubmittedEvent.joins(:arbius_miner).count
      @current_page = page
      @per_page = per_page
      @arbitrum_block_explorer = ENV.fetch("ARBITRUM_BLOCK_EXPLORER")
    end

    def show
      @solution_info = Arbius::Public::SolutionsService.new.solution(solution_submitted_event_id: params[:id])
      @arbitrum_block_explorer = ENV.fetch("ARBITRUM_BLOCK_EXPLORER")
    end
  end
end
