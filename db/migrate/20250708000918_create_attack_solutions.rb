class CreateAttackSolutions < ActiveRecord::Migration[8.0]
  def change
    create_table :arbius_attack_solutions, id: :uuid do |t|
      t.string :task, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
