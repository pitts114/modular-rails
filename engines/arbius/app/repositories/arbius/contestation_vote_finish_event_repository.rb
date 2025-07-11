module Arbius
  class ContestationVoteFinishEventRepository
    class RecordNotUnique < StandardError; end
    class RecordInvalid < StandardError; end

    def self.save!(attributes:)
      Arbius::ApplicationRecord.transaction do
        arbius_ethereum_event_detail = Arbius::EthereumEventDetail.create!(
          ethereum_event_id: attributes[:ethereum_event_id],
          block_hash: attributes[:block_hash],
          block_number: attributes[:block_number],
          chain_id: attributes[:chain_id],
          contract_address: attributes[:contract_address],
          transaction_hash: attributes[:transaction_hash],
          transaction_index: attributes[:transaction_index]
        )
        Arbius::ContestationVoteFinishEvent.create!(
          task_id: attributes[:task_id],
          start_idx: attributes[:start_idx],
          end_idx: attributes[:end_idx],
          arbius_ethereum_event_details_id: arbius_ethereum_event_detail.id
        )
      rescue ActiveRecord::RecordNotUnique => e
        raise RecordNotUnique, "Record already exists: #{e.message}"
      rescue ActiveRecord::RecordInvalid => e
        raise RecordInvalid, "Record is invalid: #{e.message}"
      end
    end
  end
end
