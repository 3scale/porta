class RemoveForeignKeyEventsAccounts < ActiveRecord::Migration
  def change
    remove_foreign_key :event_store_events, column: :provider_id
  end
end
