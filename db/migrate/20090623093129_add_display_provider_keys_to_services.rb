class AddDisplayProviderKeysToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :display_provider_keys, :boolean, :default => false
  end

  def self.down
    remove_column :services, :display_provider_keys
  end
end
