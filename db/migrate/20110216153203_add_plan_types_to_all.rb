class AddPlanTypesToAll < ActiveRecord::Migration
  def self.up
    add_column :pricing_rules, :plan_type, :string, :default => 'ApplicationPlan', :null => false
    add_column :usage_limits, :plan_type, :string, :default => 'ApplicationPlan', :null => false
    add_column :features_plans, :plan_type, :string, :default => 'ApplicationPlan', :null => false
  end

  def self.down
  end
end
