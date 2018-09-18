class AddCustomPlansEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :custom_plans_enabled, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :settings, :custom_plans_enabled
  end
end
