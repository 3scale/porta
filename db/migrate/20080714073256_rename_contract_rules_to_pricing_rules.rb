class RenameContractRulesToPricingRules < ActiveRecord::Migration
  def self.up
    rename_table :contract_rules, :pricing_rules
  end

  def self.down
    rename_table :pricing_rules, :contract_rules
  end
end
