class MoveSomeSettingsToService < ActiveRecord::Migration
  def self.up
    add_column :services, :mandatory_app_key, :boolean, :default => false
    add_column :services, :buyer_key_regenerate_enabled, :boolean, :default => true

    execute "UPDATE services SET mandatory_app_key = (SELECT mandatory_app_key from settings where settings.account_id = services.account_id)"
    execute "UPDATE services SET buyer_key_regenerate_enabled = (SELECT buyer_key_regenerate_enabled from settings where settings.account_id = services.account_id)"

    remove_column :settings, :mandatory_app_key
    remove_column :settings, :buyer_key_regenerate_enabled
 end

  def self.down
    remove_column :services, :mandatory_app_key
    remove_column :services, :buyer_key_regenerate_enabled
    add_column :settings, :mandatory_app_key, :boolean, :default => false
    add_column :settings, :buyer_key_regenerate_enabled, :boolean, :default => true
  end
end
