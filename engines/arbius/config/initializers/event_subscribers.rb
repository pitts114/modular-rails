require 'address_provider'

# ActiveSupport::Notifications.subscribe(/\Aethereum\./) do |name, start, finish, id, payload|
#   # Example: Log the event (replace with your own logic)
#   Rails.logger.info "Received event: #{name} with payload: #{payload.inspect}"
#   # You can add custom handling for specific event names here
#   # if name == "ethereum.1_0x1234abcd_some_event"
#   #   ...
#   # end
# end

# arbitrum_chain_id = ENV.fetch('ARBITRUM_CHAIN_ID')
arbitrum_chain_id = Eth::Client.create(ENV.fetch('ETHEREUM_NODE_URL')).chain_id
arbitrum_engine_contract_address = AddressProvider.engine_contract_address

arbitrum_engine_event_name_prefix = "ethereum.#{arbitrum_chain_id}_#{arbitrum_engine_contract_address}"

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_task_submitted") do |event|
  Arbius::TaskSubmittedHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_signal_commitment") do |event|
  Arbius::SignalCommitmentHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_solution_submitted") do |event|
  Arbius::SolutionSubmittedHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_solution_claimed") do |event|
  Arbius::SolutionClaimedHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_contestation_submitted") do |event|
  Arbius::ContestationSubmittedHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_contestation_vote") do |event|
  Arbius::ContestationVoteHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_contestation_vote_finish") do |event|
  Arbius::ContestationVoteFinishHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("#{arbitrum_engine_event_name_prefix}_validator_deposit") do |event|
  Arbius::ValidatorDepositHandler.new.call(payload: event.payload)
end

ActiveSupport::Notifications.subscribe("ethereum.transaction_status_updated") do |event|
  Arbius::TransactionStatusUpdateHandler.new.call(payload: event.payload)
end
