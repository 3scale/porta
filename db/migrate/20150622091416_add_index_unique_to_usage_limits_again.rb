class AddIndexUniqueToUsageLimitsAgain < ActiveRecord::Migration
  def change
    add_index(:usage_limits, [:metric_id, :plan_id, :period], unique: true)
  end
end
