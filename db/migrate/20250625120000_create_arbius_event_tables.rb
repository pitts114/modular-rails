class CreateArbiusEventTables < ActiveRecord::Migration[6.1]
  def change
    create_table :arbius_ethereum_event_details, id: :uuid do |t|
      t.uuid :ethereum_event_id, null: false
      t.string :block_hash, null: false
      t.integer :block_number, null: false
      t.integer :chain_id, null: false
      t.string :contract_address, null: false
      t.string :transaction_hash, null: false
      t.integer :transaction_index, null: false
      t.timestamps

      t.index :ethereum_event_id, unique: true
      t.index :transaction_hash
    end

    create_table :arbius_task_submitted_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :task_id, null: false
      t.string :model, null: false
      t.numeric :fee, precision: 78, scale: 0, null: false
      t.string :sender, null: false
      t.timestamps

      t.index :task_id
      t.index :sender
    end

    create_table :arbius_signal_commitment_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :address, null: false
      t.string :commitment, null: false
      t.timestamps

      t.index :address
      t.index :commitment
    end

    create_table :arbius_solution_submitted_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :address, null: false
      t.string :task, null: false
      t.timestamps

      t.index :address
      t.index :task
    end

    create_table :arbius_contestation_submitted_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :address, null: false
      t.string :task, null: false
      t.timestamps

      t.index :address
      t.index :task
    end

    create_table :arbius_contestation_vote_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :address, null: false
      t.string :task, null: false
      t.boolean :yea, null: false
      t.timestamps

      t.index :address
      t.index :task
    end

    create_table :arbius_sent_contestation_vote_events, id: :uuid do |t|
      t.string :address, null: false
      t.string :task, null: false
      t.boolean :yea, null: false
      t.timestamps

      t.index :address
      t.index :task

      t.index [ :task, :address ], unique: true
    end

    create_table :arbius_solution_claimed_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :address, null: false
      t.string :task, null: false
      t.timestamps

      t.index :address
      t.index :task
    end

    create_table :arbius_contestation_vote_finish_events, id: :uuid do |t|
      t.uuid :arbius_ethereum_event_details_id, null: false
      t.string :task_id, null: false # 'id' is reserved in Rails, so use task_id
      t.integer :start_idx, null: false
      t.integer :end_idx, null: false
      t.timestamps

      t.index :task_id
    end
  end
end
