module Arbius
  class AddressShuffleService
    def initialize(random: Random)
      @random = random
    end

    def shuffle(addresses:, task_id:)
      addresses.shuffle(random: @random.new(task_id.hash))
    end
  end
end
