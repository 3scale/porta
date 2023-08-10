class AddPrimaryKeyToFeaturesPlans < ActiveRecord::Migration[5.2]
  def up
    if System::Database.mysql?
      execute 'ALTER TABLE features_plans ADD PRIMARY KEY (plan_id, feature_id)'
      remove_index :features_plans, [:plan_id, :feature_id]
    elsif System::Database.postgres?
      execute 'ALTER TABLE features_plans ADD CONSTRAINT features_plans_pk PRIMARY KEY (plan_id, feature_id)'
      remove_index :features_plans, [:plan_id, :feature_id]
    else
      remove_index :features_plans, [:plan_id, :feature_id]
      execute 'ALTER TABLE FEATURES_PLANS ADD PRIMARY KEY (PLAN_ID, FEATURE_ID)'
    end
  end
end
