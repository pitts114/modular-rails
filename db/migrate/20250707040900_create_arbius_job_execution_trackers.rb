# frozen_string_literal: true

class CreateArbiusJobExecutionTrackers < ActiveRecord::Migration[7.0]
  def change
    create_table :arbius_job_execution_trackers, id: :uuid do |t|
      t.string :job_name, null: false
      t.timestamp :last_executed_at, null: false
      t.timestamps
    end

    add_index :arbius_job_execution_trackers, :job_name, unique: true
  end
end
