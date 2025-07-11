# frozen_string_literal: true

module Arbius
  class ShutdownService
    def initialize(flipper: Flipper)
      @flipper = flipper
    end

    def call
      @flipper.disable(:defend_solution)
      @flipper.disable(:bulk_bogus_auto_mine)
      @flipper.disable(:attack_solution)
    end
  end
end
