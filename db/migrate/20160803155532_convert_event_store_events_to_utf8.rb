class ConvertEventStoreEventsToUtf8 < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE event_store_events convert to character set utf8;'
  end

  def down
    execute 'ALTER TABLE event_store_events convert to character set latin1;'
  end
end
