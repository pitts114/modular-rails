class CreateMinerContestationVoteChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :arbius_miner_contestation_vote_checks, id: :uuid do |t|
      t.string :task_id, null: false
      t.timestamps

      t.index :task_id, unique: true
    end
  end
end
