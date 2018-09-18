class RenameUsageLimitsIndices < ActiveRecord::Migration
  def change
    rename_index :usage_limits, 'idx_metric_id', 'idx_usage_limits_metric_id'
    rename_index :usage_limits, 'idx_plan_id', 'idx_usage_limits_plan_id'
  end
end
