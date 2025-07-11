class CreateEthereumAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ethereum_addresses, id: :uuid do |t|
      t.string :address, null: false, unique: true
      t.timestamps
    end
    add_index :ethereum_addresses, :address, unique: true
  end
end
