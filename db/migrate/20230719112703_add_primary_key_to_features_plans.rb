class AddPrimaryKeyToFeaturesPlans < ActiveRecord::Migration[5.2]
  def up
    remove_index :features_plans, [:plan_id, :feature_id]

    if System::Database.mysql?
      execute 'ALTER TABLE features_plans ADD PRIMARY KEY (plan_id, feature_id)'
    elsif System::Database.postgres?
      execute 'ALTER TABLE features_plans ADD CONSTRAINT features_plans_pk PRIMARY KEY (plan_id, feature_id)'
    else
      execute 'ALTER TABLE FEATURES_PLANS ADD PRIMARY KEY (PLAN_ID, FEATURE_ID)'
    end
  end

  def down
    if System::Database.mysql?
      execute 'ALTER TABLE features_plans DROP PRIMARY KEY'
    elsif System::Database.postgres?
      execute 'ALTER TABLE features_plans DROP CONSTRAINT features_plans_pk'
    else
      execute 'ALTER TABLE FEATURES_PLANS DROP PRIMARY KEY'
    end

    add_index :features_plans, [:plan_id, :feature_id]
  end
end
