module Arbius
  class ShutdownAutoMineService
    def initialize(flipper: Flipper)
      @flipper = flipper
    end

    def call
      @flipper.disable(:bulk_bogus_auto_mine)
    end
  end
end
