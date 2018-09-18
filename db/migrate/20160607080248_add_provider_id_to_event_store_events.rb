class AddProviderIdToEventStoreEvents < ActiveRecord::Migration
  def change
    add_column :event_store_events, :provider_id, :integer, limit: 8

    add_index :event_store_events, :provider_id
  end
end
