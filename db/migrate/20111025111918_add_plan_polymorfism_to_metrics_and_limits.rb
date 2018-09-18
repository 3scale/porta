class AddPlanPolymorfismToMetricsAndLimits < ActiveRecord::Migration
  def self.up
    add_column :plan_metrics, :plan_type, :string, :null => false, :default => 'ApplicationPlan'
    change_column_default(:plan_metrics, :plan_type, nil)
  end

  def self.down
    remove_column :plan_metrics, :plan_type
  end
end
