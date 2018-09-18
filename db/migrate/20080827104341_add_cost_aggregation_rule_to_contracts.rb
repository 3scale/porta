class AddCostAggregationRuleToContracts < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.string :cost_aggregation_rule, :null => false, :default => 'sum'
    end
  end

  def self.down
    change_table :contracts do |t|
      t.remove :cost_aggregation_rule
    end
  end
end
