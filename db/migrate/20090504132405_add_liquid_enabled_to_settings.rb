class AddLiquidEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :liquid_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :liquid_enabled
  end
end
