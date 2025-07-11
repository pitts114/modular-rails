module Admin
  class AttacksController < ApplicationController
    def index
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = 50
      offset = (page - 1) * per_page
      @attacks = Arbius::Public::AttacksService.new.attacks(limit: per_page, offset: offset)
      @total_count = Arbius::AttackSolution.count
      @current_page = page
      @per_page = per_page
      @arbitrum_block_explorer = ENV.fetch("ARBITRUM_BLOCK_EXPLORER")
    end

    def show
      @attack_info = Arbius::Public::AttacksService.new.attack(attack_solution_id: params[:id])
      @arbitrum_block_explorer = ENV.fetch("ARBITRUM_BLOCK_EXPLORER")
    end
  end
end
