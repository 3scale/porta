class AddBuyersManageAppsToService < ActiveRecord::Migration
  def self.up
    add_column :services, :buyers_manage_apps, :boolean, :default => true
  end

  def self.down
    remove_column :services, :buyers_manage_apps
  end
end
