class AddCustomKeysEnabledToService < ActiveRecord::Migration
  def self.up
    add_column :services, :custom_keys_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :services, :custom_keys_enabled
  end
end
