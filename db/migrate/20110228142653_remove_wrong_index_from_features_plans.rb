class RemoveWrongIndexFromFeaturesPlans < ActiveRecord::Migration
  def self.up
    remove_index(:features_plans,
                 :name => "index_contracts_features_on_contract_id_and_feature_id")
    add_index :features_plans, [:plan_id, :feature_id]
  end

  def self.down
    remove_index(:features_plans,
                 :name => "index_features_plans_on_plan_id_and_feature_id")
    add_index(:features_plans, [:plan_id, :feature_id], :unique => true,
              :name => "index_contracts_features_on_contract_id_and_feature_id")
  end
end
