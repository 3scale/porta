class RenamePlanMetricsIndices < ActiveRecord::Migration
  def change
    rename_index :plan_metrics, 'idx_metric_id', 'idx_plan_metrics_metric_id'
    rename_index :plan_metrics, 'idx_plan_id', 'idx_plan_metrics_plan_id'
  end
end
