class CreateEthereumTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :ethereum_transactions, id: :uuid do |t|
      t.string :from, null: false
      t.string :to, null: false
      t.numeric :value, precision: 78, scale: 0
      t.integer :chain_id, null: false
      t.integer :nonce
      t.text :data
      t.string :tx_hash
      t.text :raw_tx
      t.text :signed_tx
      t.string :status, null: false, default: 'pending'
      t.datetime :broadcasted_at
      t.datetime :confirmed_at
      t.json :context
      t.timestamps
    end
    add_index :ethereum_transactions, [ :from, :chain_id ], name: 'index_eth_tx_on_from_chainid'
    add_index :ethereum_transactions, :tx_hash, unique: true
    add_index :ethereum_transactions, [ :from, :chain_id, :status, :created_at ], name: 'index_eth_tx_on_from_chainid_status_created'
  end
end
