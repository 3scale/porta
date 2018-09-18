class CreateUsageLimitViolations < ActiveRecord::Migration
  def self.up
    create_table :usage_limit_violations do |table|
      table.belongs_to :cinstance
      table.belongs_to :usage_limit
      table.string :period_name
      table.datetime :period_start
      table.string :metric_name
      table.integer :limit_value, :null => false, :default => 0
      table.integer :actual_value, :null => false, :default => 0
      table.timestamps
    end
  end

  def self.down
    drop_table :usage_limit_violations
  end
end
