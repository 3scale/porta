class CreateFinanceBillingStrategies < ActiveRecord::Migration
  def self.up
    create_table :billing_strategies do |t|
      t.references :account #, :null => false
      t.boolean :prepaid, :default => false
      t.boolean :charging_enabled, :default => false
      t.integer :charging_retry_delay, :default => 3
      t.integer :charging_retry_times, :default => 3
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_strategies
  end
end
