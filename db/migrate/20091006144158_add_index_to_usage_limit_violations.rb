class AddIndexToUsageLimitViolations < ActiveRecord::Migration
  def self.up
    add_index :usage_limit_violations, [:created_at, :period_start, :period_end], :name => "violations_timestamped_index"
  end

  def self.down
    remove_index :usage_limit_violations, "violations_timestamped_index"
  end
end
