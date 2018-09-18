class IncreaseMinMaxPricingRules < ActiveRecord::Migration
  def up
    change_column :pricing_rules, :min, :integer, limit: 8
    change_column :pricing_rules, :max, :integer, limit: 8
  end

  def down
    change_column :pricing_rules, :min, :integer, limit: nil
    change_column :pricing_rules, :max, :integer, limit: nil
  end
end
