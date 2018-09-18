class MandatoryCostPerUnitForPricingRule < ActiveRecord::Migration
  def self.up
    change_column_default :pricing_rules, :cost_per_unit, 0
    change_column_null :pricing_rules, :cost_per_unit, false
  end

  def self.down
    change_column_null :pricing_rules, :cost_per_unit, true
    change_column_default :pricing_rules, :cost_per_unit, nil
  end
end
