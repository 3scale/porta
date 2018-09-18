class FixDefaultPolymorphicTypes < ActiveRecord::Migration
  def self.up
    execute %{ALTER TABLE features_plans ALTER COLUMN plan_type DROP DEFAULT}
    execute %{ALTER TABLE pricing_rules ALTER COLUMN plan_type DROP DEFAULT}
    execute %{ALTER TABLE plans ALTER COLUMN type DROP DEFAULT}
    execute %{ALTER TABLE plans ALTER COLUMN issuer_type DROP DEFAULT}

    execute %{UPDATE features_plans SET plan_type = 'Plan' WHERE plan_type = 'ApplicationPlan'}
    execute %{UPDATE pricing_rules SET plan_type = 'Plan' WHERE plan_type = 'ApplicationPlan'}
    execute %{UPDATE usage_limits SET plan_type = 'Plan' WHERE plan_type = 'ApplicationPlan'}
    execute %{UPDATE plan_metrics SET plan_type = 'Plan' WHERE plan_type = 'ApplicationPlan'}
  end

  def self.down
    change_column_default :features_plans, :plan_type, 'ApplicationPlan'
    change_column_default :pricing_rules, :plan_type, 'ApplicationPlan'
    change_column_default :plans, :type, 'ApplicationPlan'
    change_column_default :plans, :issuer_type, 'Service'
  end
end
