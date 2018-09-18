class EventStoreEventsDataAllowNullValue < ActiveRecord::Migration
  def change
    change_column :event_store_events, :data, :text, null: true
  end
end
