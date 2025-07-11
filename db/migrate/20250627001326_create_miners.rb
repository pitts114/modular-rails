class CreateMiners < ActiveRecord::Migration[8.0]
  def change
    create_table :arbius_miners, id: :uuid do |t|
      t.string :address, null: false
      t.timestamps

      t.index :address, unique: true
    end
  end
end
