class AddSignupsEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :signups_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :signups_enabled
  end
end
