class CreateEventPollerStates < ActiveRecord::Migration[6.1]
  def change
    create_table :ethereum_event_poller_states, id: :uuid do |t|
      t.string :poller_name, null: false
      t.integer :last_processed_block, null: false
      t.timestamps
    end
    add_index :ethereum_event_poller_states, :poller_name, unique: true
  end
end
