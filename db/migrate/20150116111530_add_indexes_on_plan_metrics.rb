class AddIndexesOnPlanMetrics < ActiveRecord::Migration
  def up
    add_index :plan_metrics, :metric_id, :name => 'idx_metric_id'
    add_index :plan_metrics, :plan_id,   :name => 'idx_plan_id'
  end

  def down
    remove_index :plan_metrics, :name => 'idx_metric_id'
    remove_index :plan_metrics, :name => 'idx_plan_id'
  end
end
