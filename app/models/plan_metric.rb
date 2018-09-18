class PlanMetric < ApplicationRecord
  belongs_to :plan, :polymorphic => true
  belongs_to :metric

  attr_protected :plan_id, :metric_id, :plan_type, :tenant_id

  validates :plan, presence: true
  validates :metric, presence: true
end
