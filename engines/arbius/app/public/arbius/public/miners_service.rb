module Arbius
  module Public
    class MinersService
      def initialize(
        model: Arbius::Miner
      )
        @model = model
      end

      def miners
        @model.all
      end
    end
  end
end
