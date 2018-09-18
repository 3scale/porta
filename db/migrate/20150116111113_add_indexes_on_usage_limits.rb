class AddIndexesOnUsageLimits < ActiveRecord::Migration
  def up
    add_index :usage_limits, :metric_id,:name => 'idx_metric_id'
    add_index :usage_limits, :plan_id,  :name => 'idx_plan_id'
  end

  def down
    remove_index :usage_limits, :name => 'idx_metric_id'
    remove_index :usage_limits, :name => 'idx_plan_id'
  end
end
