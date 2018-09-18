class AddAccountPlanChangePermissionToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :change_account_plan_permission, :string, :default => "request", :null => false
  end

  def self.down
    remove_column :settings, :change_account_plan_permission
  end
end
