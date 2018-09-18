class AddMonthlyBillingEnabledSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :monthly_billing_enabled, :boolean, :default => true, :null => false
    # now set it to false for all enterprise providers
    execute %{
      UPDATE settings SET monthly_billing_enabled = false AND monthly_charging_enabled = false
      WHERE account_id IN (SELECT id FROM accounts where provider = true)
    }
  end

  def self.down
    remove_column :settings, :monthly_billing_enabled
  end
end
