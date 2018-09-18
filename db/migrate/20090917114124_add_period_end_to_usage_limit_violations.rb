class AddPeriodEndToUsageLimitViolations < ActiveRecord::Migration
  def self.up
    add_column :usage_limit_violations, :period_end, :datetime
  end

  def self.down
    remove_column :usage_limit_violations, :period_end
  end
end
