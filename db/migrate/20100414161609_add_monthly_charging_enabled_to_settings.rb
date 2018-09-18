class AddMonthlyChargingEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :monthly_charging_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :monthly_charging_enabled
  end
end
