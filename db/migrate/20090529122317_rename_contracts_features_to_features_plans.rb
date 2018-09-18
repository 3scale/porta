class RenameContractsFeaturesToFeaturesPlans < ActiveRecord::Migration
  def self.up
    rename_table :contracts_features, :features_plans
    rename_column :features_plans, :contract_id, :plan_id
  end

  def self.down
    rename_column :features_plans, :plan_id, :contract_id
    rename_table :features_plans, :contracts_features
  end
end
