class AddIndexCreatedAtOnEventStoreEvents < ActiveRecord::Migration
  def change
    add_index :event_store_events, :created_at
  end
end
