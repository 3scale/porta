class LogEntriesIndexes < ActiveRecord::Migration
  def self.up
    add_index :log_entries, [ :provider_id ]
  end

  def self.down
    remove_index :log_entries, [ :provider_id ]
  end
end
