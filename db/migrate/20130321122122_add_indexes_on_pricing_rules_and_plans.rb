class AddIndexesOnPricingRulesAndPlans < ActiveRecord::Migration

  def change
    add_index :pricing_rules, [:plan_id, :plan_type]
    add_index :plans,  [:cost_per_month, :setup_fee]
  end
end
