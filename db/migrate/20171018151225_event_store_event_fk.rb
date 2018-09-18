class EventStoreEventFk < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL_STATEMENT.strip_heredoc
          DELETE event_store_events
          FROM event_store_events
          LEFT OUTER JOIN accounts a
          ON provider_id = a.id
          WHERE a.id IS NULL;
        SQL_STATEMENT
      end
    end
    add_foreign_key :event_store_events, :accounts, column: :provider_id, on_delete: :cascade
  end
end
