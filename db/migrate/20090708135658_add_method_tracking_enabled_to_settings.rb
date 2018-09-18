class AddMethodTrackingEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :method_tracking_enabled, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :settings, :method_tracking_enabled
  end
end
