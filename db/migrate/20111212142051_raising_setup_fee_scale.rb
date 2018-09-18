class RaisingSetupFeeScale < ActiveRecord::Migration
  def self.up
    change_column :plans, :setup_fee, :decimal, :precision => 20, :scale => 4, :default => 0.0, :null => false
  end

  def self.down
    change_column :plans, :setup_fee, :decimal, :precision => 20, :scale => 2, :default => 0.0, :null => false
  end
end
