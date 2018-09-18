class AddPlanChangingSettingAttributesToService < ActiveRecord::Migration
  def self.up
    add_column :services, :buyer_plan_change_permission, :string, :default => 'request'
  end

  def self.down
    remove_column :services, :buyer_plan_change_permission
  end
end