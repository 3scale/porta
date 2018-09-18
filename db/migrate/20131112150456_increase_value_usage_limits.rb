class IncreaseValueUsageLimits < ActiveRecord::Migration
  def up
    change_column :usage_limits, :value, :integer, limit: 8
  end

  def down
    change_column :usage_limits, :value, :integer, limit: nil
  end
end
