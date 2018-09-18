class AddDownloadsEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :downloads_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :downloads_enabled
  end
end
