class PricingRulesPlanTypeDefaultValue < ActiveRecord::Migration
  def up
    change_column :pricing_rules, :plan_type, :string, default: 'Plan'
  end

  def down
    change_column :pricing_rules, :plan_type, :string, default: nil
  end
end
