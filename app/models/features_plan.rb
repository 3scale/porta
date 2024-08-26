class FeaturesPlan < ApplicationRecord
  belongs_to :feature
  belongs_to :plan, :polymorphic => true

  validate :feature_scope_matches_plan_class?

  attr_protected :plan_id, :feature_id, :plan_type, :tenant_id

  private

  def feature_scope_matches_plan_class?
    # plan is nil (e.g. customize uses plan.features_plans.build) then we
    # have to loose the check
    if self.plan && self.feature && self.feature.scope != self.plan.class.to_s
      errors.add :plan_type, "mismatch"
    end
  end

end
