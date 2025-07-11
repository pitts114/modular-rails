class AddStatusToSentContestationVoteEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :arbius_sent_contestation_vote_events, :status, :string, default: 'pending', null: false
    add_index :arbius_sent_contestation_vote_events, :status

    # Backfill existing records to 'confirmed' status
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE arbius_sent_contestation_vote_events
          SET status = 'confirmed'
          WHERE status = 'pending'
        SQL
      end
    end
  end
end
