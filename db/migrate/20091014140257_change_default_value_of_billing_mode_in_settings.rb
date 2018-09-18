class ChangeDefaultValueOfBillingModeInSettings < ActiveRecord::Migration
  def self.up
    change_column :settings, :billing_mode, :string, :null => true, :default => nil
  end

  def self.down
    change_column :settings, :billing_mode, :string, :null => false, :default => 'prepaid'
  end
end
