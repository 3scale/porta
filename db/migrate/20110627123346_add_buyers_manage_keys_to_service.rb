class AddBuyersManageKeysToService < ActiveRecord::Migration
  def self.up
    add_column :services, :buyers_manage_keys, :boolean, :default => true
  end

  def self.down
    remove_column :services, :buyers_manage_keys
  end
end
