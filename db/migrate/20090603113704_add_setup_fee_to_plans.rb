class AddSetupFeeToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :setup_fee, :decimal, :precision => 20, :scale => 2, :default => 0.0, :null => false
  end

  def self.down
    remove_column :plans, :setup_fee
  end
end
