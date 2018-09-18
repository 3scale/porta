class AddBuyerKeyRegenerateEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :buyer_key_regenerate_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :buyer_key_regenerate_enabled
  end
end
