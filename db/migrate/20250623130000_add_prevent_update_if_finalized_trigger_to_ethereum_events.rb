class AddPreventUpdateIfFinalizedTriggerToEthereumEvents < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION prevent_update_if_finalized()
      RETURNS trigger AS $$
      BEGIN
        IF OLD.finalized = true THEN
          RAISE EXCEPTION 'Cannot update a finalized event';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER prevent_update_if_finalized_trigger
      BEFORE UPDATE ON ethereum_events
      FOR EACH ROW
      EXECUTE FUNCTION prevent_update_if_finalized();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS prevent_update_if_finalized_trigger ON ethereum_events;
      DROP FUNCTION IF EXISTS prevent_update_if_finalized();
    SQL
  end
end
