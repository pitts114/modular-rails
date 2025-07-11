module Arbius
  class WaiBulkBogusAutoMineJob < ApplicationJob
    queue_as :arbius_bogus_mine

    def perform
      Arbius::BulkBogusAutoMineService.new.call(
        from: Arbius::Miner.first.address,
        model: '0xa473c70e9d7c872ac948d20546bc79db55fa64ca325a4b229aaffddb7f86aae0',
        fee: Arbius::ModelFees::WAI_FEE,
        input: { prompt: 'I will protect honest miners. I will destroy dishonest miners.' },
        n: ENV.fetch('ARBIUS_BULK_BOGUS_AUTO_MINE_N').to_i
      )
    end
  end
end
