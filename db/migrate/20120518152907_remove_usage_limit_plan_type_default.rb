class RemoveUsageLimitPlanTypeDefault < ActiveRecord::Migration
  def self.up
    execute %{ALTER TABLE usage_limits ALTER COLUMN plan_type DROP DEFAULT}
  end

  def self.down
    change_column_default :usage_limits, :plan_type, 'ApplicationPlan'
  end
end
