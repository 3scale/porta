class AddMultipleCinstancesAllowedToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :multiple_cinstances_allowed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :accounts, :multiple_cinstances_allowed
  end
end
