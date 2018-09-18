class AddAccountPlanSwitchToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :account_plans_switch, :string
    execute %{ UPDATE settings SET account_plans_switch = 'hidden' }
    change_column_null :settings, :account_plans_switch, false
  end

  def self.down
    remove_column :settings, :account_plans_switch
  end
end
