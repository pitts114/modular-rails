class AddIndexTaskSubmittedEthereumEventDetails < ActiveRecord::Migration[8.0]
  def change
    add_index :arbius_task_submitted_events, :arbius_ethereum_event_details_id
  end
end
