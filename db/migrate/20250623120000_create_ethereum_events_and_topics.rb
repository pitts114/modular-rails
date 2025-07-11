class CreateEthereumEventsAndTopics < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :ethereum_events, id: :uuid do |t|
      t.string :address, null: false
      t.string :block_hash, null: false
      t.integer :block_number, null: false, limit: 8
      t.string :transaction_hash, null: false
      t.integer :transaction_index, null: false
      t.integer :log_index, null: false
      t.boolean :removed, null: false, default: false
      t.string :data, null: false
      t.integer :chain_id, null: false
      t.boolean :finalized, null: false, default: false
      t.jsonb :raw_event, null: false
      t.timestamps

      t.index [ :chain_id, :block_hash, :log_index ], unique: true, name: 'index_eth_events_on_chain_block_log'
    end

    create_table :ethereum_event_topics, id: :uuid do |t|
      t.references :ethereum_event, null: false, type: :uuid, foreign_key: true
      t.integer :topic_index, null: false
      t.string :topic, null: false
      t.timestamps

      t.index [ :ethereum_event_id, :topic_index ], unique: true, name: 'index_eth_event_topics_on_event_and_topic_index'
    end
  end
end
